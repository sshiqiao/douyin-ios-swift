//
//  WebDownloadOperation.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class WebDownloadOperation:Operation {
    
    //下载回调block
    var progressBlock:WebDownloaderProgressBlock?
    var completedBlock:WebDownloaderCompletedBlock?
    var cancelBlock:WebDownloaderCancelBlock?
    
    //网络请求
    var session:URLSession?
    var dataTask:URLSessionTask?
    var request:URLRequest?
    
    var imageData:Data?           //用于存储网络资源数据
    var expectedSize:Int64?       //网络资源数据总大小
    
    var _executing:Bool = false  //指定_executing用于记录任务是否执行
    var _finished:Bool = false   //指定_finished用于记录任务是否完成
    
    //初始化数据
    init(request:URLRequest, progress:@escaping WebDownloaderProgressBlock, completed:@escaping WebDownloaderCompletedBlock, cancel:@escaping WebDownloaderCancelBlock) {
        super.init()
        self.request = request
        self.progressBlock = progress
        self.completedBlock = completed
        self.cancelBlock = cancel
    }
    
    override func start() {
        willChangeValue(forKey: "isExecuting")
        _executing = true
        didChangeValue(forKey: "isExecuting")
        
        //判断任务执行前是否取消了任务
        if(self.isCancelled) {
            done()
            return
        }
        
        //创建网络资源下载请求，并设置网络请求代理
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15
        
        session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: request!)
        dataTask?.resume()
    }
    
    //重写isExecuting方法
    override var isExecuting: Bool {
        return _executing
    }
    
    //重写isFinished方法
    override var isFinished: Bool {
        return _finished
    }
    
    //重写isAsynchronous方法
    override var isAsynchronous: Bool {
        return true
    }
    
    //取消任务
    override func cancel() {
        objc_sync_enter(self)
        done()
        objc_sync_exit(self)
    }
    
    //更新任务状态
    func done() {
        super.cancel()
        if(_executing) {
            willChangeValue(forKey: "isFinished")
            willChangeValue(forKey: "isExecuting")
            _finished = true
            _executing = false
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
            reset()
        }
    }
    
    //重置请求数据
    func reset() {
        if (dataTask != nil) {
            dataTask?.cancel()
        }
        if (session != nil) {
            session?.invalidateAndCancel()
            session = nil
        }
    }
}


//URLSessionDataDelegate, URLSessionDelegate
extension WebDownloadOperation:URLSessionDataDelegate, URLSessionDelegate {
    //网络资源下载请求获得响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = dataTask.response as! HTTPURLResponse
        let code = httpResponse.statusCode
        if(code == 200) {
            completionHandler(URLSession.ResponseDisposition.allow)
            imageData = Data.init()
            expectedSize = httpResponse.expectedContentLength
        }else {
            completionHandler(URLSession.ResponseDisposition.cancel)
        }
    }
    
    //网络资源下载请求完毕
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(completedBlock != nil) {
            if(error != nil) {
                let err = error! as NSError
                if(err.code == NSURLErrorCancelled) {
                    cancelBlock?()
                }else {
                    completedBlock?(nil, error, false)
                }
            }else {
                completedBlock?(imageData!, nil, true)
            }
        }
        done()
    }
    
    //接收网络资源下载数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        imageData?.append(data)
        if(progressBlock != nil) {
            progressBlock?(Int64(imageData?.count ?? 0), expectedSize ?? 0)
        }
    }
    
    //网络缓存数据复用
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        let cacheResponse = proposedResponse
        if(request?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData) {
            completionHandler(nil)
            return
        }
        completionHandler(cacheResponse)
    }
}
