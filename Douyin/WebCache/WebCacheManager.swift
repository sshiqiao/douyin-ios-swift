//
//  WebCacheHelper.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

//缓存清除完毕后的回调block
typealias WebCacheClearCompletedBlock = (_ cacheSize:String) -> Void

//缓存查询完毕后的回调block，data返回类型包括NSString缓存文件路径、NSData格式缓存数据
typealias WebCacheQueryCompletedBlock = (_ data:Any?, _ hasCache:Bool) -> Void

//网络资源下载进度的回调block
typealias WebDownloaderProgressBlock = (_ receivedSize:Int64, _ expectedSize:Int64) -> Void

//网络资源下载完毕后的回调block
typealias WebDownloaderCompletedBlock = (_ data:Data?, _ error:Error?, _ finished:Bool) -> Void

//网络资源下载取消后的回调block
typealias WebDownloaderCancelBlock = () -> Void

class WebCacheManager:NSObject {
    
    var memCache:NSCache<NSString, AnyObject>?
    var fileManager:FileManager = FileManager.default
    var diskCacheDirectoryURL:URL?
    var ioQueue:DispatchQueue?
    
    private static let instance = { () -> WebCacheManager in
        return WebCacheManager.init()
    }()
    
    private override init() {
        super.init()
        self.memCache = NSCache.init()
        self.memCache?.name = "webCache"
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths.last
        let diskCachePath = path! + "/webCache"
        
        var isDirectory:ObjCBool = false
        let isExisted = fileManager.fileExists(atPath: diskCachePath, isDirectory: &isDirectory)
        if(!isDirectory.boolValue || !isExisted) {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create disk cache file error:" + error.localizedDescription)
            }
        }
        diskCacheDirectoryURL = URL.init(fileURLWithPath: diskCachePath)
        ioQueue = DispatchQueue.init(label: "com.start.webcache")
        
    }
    
    class func shared() -> WebCacheManager {
        return instance
    }
    
    //根据key值从内存和本地磁盘中查询缓存数据
    func queryDataFromMemory(key:String, cacheQueryCompletedBlock:WebCacheQueryCompletedBlock) -> Operation{
        return queryDataFromMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }
    
    //根据key值从内存和本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
    func queryDataFromMemory(key:String, cacheQueryCompletedBlock:WebCacheQueryCompletedBlock, exten:String?) -> Operation {
        let operation = Operation.init()
        ioQueue?.sync {
            if(operation.isCancelled) {
                return
            }
            if let data = self.dataFromMemoryCache(key: key) {
                cacheQueryCompletedBlock(data, true)
            } else if let data = self.dataFromDiskCache(key: key, exten: exten) {
                storeDataToMemoryCache(data: data, key: key)
                cacheQueryCompletedBlock(data, true)
            } else {
                cacheQueryCompletedBlock(nil, false)
            }
            
        }
        return operation
    }
    
    func queryURLFromDiskMemory(key:String, cacheQueryCompletedBlock:WebCacheQueryCompletedBlock) -> Operation {
        return queryURLFromDiskMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }
    
    func queryURLFromDiskMemory(key:String, cacheQueryCompletedBlock:WebCacheQueryCompletedBlock, exten:String?) -> Operation {
        let operation = Operation.init()
        ioQueue?.sync {
            if(operation.isCancelled) {
                return
            }
            let path = diskCachePathForKey(key: key, exten: exten) ?? ""
            if fileManager.fileExists(atPath: path) {
                cacheQueryCompletedBlock(path, true)
            } else {
                cacheQueryCompletedBlock(path, false)
            }
        }
        return operation
    }
    
    //根据key值从内存中查询缓存数据
    func dataFromMemoryCache(key:String) ->Data? {
        return memCache?.object(forKey: key as NSString) as? Data
    }
    
    //根据key值从本地磁盘中查询缓存数据
    func dataFromDiskCache(key:String) ->Data? {
        return dataFromDiskCache(key: key, exten: nil)
    }
    
    //根据key值从本地磁盘中查询缓存数据
    func dataFromDiskCache(key:String, exten:String?) -> Data? {
        
        if let cachePathForKey = diskCachePathForKey(key: key, exten: exten) {
            do {
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: cachePathForKey))
                return data
            } catch {}
        }
        return nil
    }
    
    //存储缓存数据到内存和本地磁盘，所查询缓存数据包含指定文件类型
    func storeDataCache(data:Data?, key:String) {
        ioQueue?.async {
            self.storeDataToMemoryCache(data: data, key: key)
            self.storeDataToDiskCache(data: data, key: key)
        }
    }
    
    //存储缓存数据到内存
    func storeDataToMemoryCache(data:Data?, key:String) {
        memCache?.setObject(data as AnyObject, forKey: key as NSString)
    }
    
    //存储缓存数据到本地磁盘
    func storeDataToDiskCache(data:Data?, key:String) {
        self.storeDataToDiskCache(data: data, key: key, exten: nil)
    }
    
    //根据key值从本地磁盘中查询缓存数据，缓存数据返回路径包含文件类型
    func storeDataToDiskCache(data:Data?, key:String, exten:String?)  {
        if let diskPath = diskCachePathForKey(key: key, exten: exten) {
            fileManager.createFile(atPath: diskPath, contents: data, attributes: nil)
        }
    }
    
    //获取key值对应的磁盘缓存文件路径，文件路径包含指定扩展名
    func diskCachePathForKey(key:String, exten:String?) -> String? {
        let fileName = md5(key: key)
        var cachePathForKey = diskCacheDirectoryURL?.appendingPathComponent(fileName).path
        if exten != nil {
            cachePathForKey = cachePathForKey! + "." + exten!
        }
        return cachePathForKey
    }
    
    //获取key值对应的磁盘缓存文件路径
    func diskCachePathForKey(key:String) -> String? {
        return diskCachePathForKey(key: key, exten: nil)
    }
    
    //清除内存和本地磁盘缓存数据
    func clearCache(cacheClearCompletedBlock:@escaping WebCacheClearCompletedBlock) {
        ioQueue?.async {
            self.clearMemoryCache()
            let cacheSize = self.clearDiskCache()
            DispatchQueue.main.async {
                cacheClearCompletedBlock(cacheSize)
            }
        }
    }
    
    //清除内存缓存数据
    func clearMemoryCache() {
        memCache?.removeAllObjects()
    }
    
    //清除本地磁盘缓存数据
    func clearDiskCache() ->String {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: (diskCacheDirectoryURL?.path)!)
            var folderSize:Float = 0
            for fileName in contents {
                let filePath = (diskCacheDirectoryURL?.path)! + "/" + fileName
                let fileDict = try fileManager.attributesOfItem(atPath: filePath)
                folderSize += fileDict[FileAttributeKey.size] as! Float
                try fileManager.removeItem(atPath: filePath)
            }
            return String.format(decimal: folderSize/1024.0/1024.0) ?? "0"
        } catch {
            print("clearDiskCache error:"+error.localizedDescription)
        }
        return "0"
    }
    
    //key值进行md5签名
    func md5(key: String) -> String{
        let cStrl = key.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStrl, CC_LONG(strlen(cStrl!)), buffer)
        var md5String = ""
        for idx in 0...15 {
            let obcStrl = String.init(format: "%02x", buffer[idx])
            md5String.append(obcStrl)
        }
        free(buffer)
        return md5String
    }
    
}

