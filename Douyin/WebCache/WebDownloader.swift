//
//  WebDownloader.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class WebDownloader:NSObject {
    
    var downloadQueue:OperationQueue?
    
    private static let instance = { () -> WebDownloader in
        return WebDownloader.init()
    }()
    
    private override init() {
        super.init()
        downloadQueue = OperationQueue.init()
        downloadQueue?.name = "com.start.webdownloader"
        downloadQueue?.maxConcurrentOperationCount = 8
    }
    
    class func shared() -> WebDownloader {
        return instance
    }
    
    func dowload(url:URL, progress:@escaping WebDownloaderProgressBlock, completed:@escaping WebDownloaderCompletedBlock, cancel:@escaping WebDownloaderCancelBlock) -> WebCombineOperation {
        var request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpShouldUsePipelining = true
        let key = url.absoluteString
        let operation = WebCombineOperation.init()
        operation.cacheOperation = WebCacheManager.shared().queryDataFromMemory(key: key, cacheQueryCompletedBlock: {[weak self] (data, hasCache) in
            if hasCache {
                completed(data as? Data, nil, true)
            }else {
                let downloadOperation = WebDownloadOperation.init(request: request, progress: progress, completed: { (data, error, finished) in
                    if (finished && error == nil) {
                        WebCacheManager.shared().storeDataCache(data: data, key: key)
                        completed(data, nil, true)
                    }else {
                        completed(data, error, false)
                    }
                }, cancel: {
                    cancel()
                })
                operation.downloadOperation = downloadOperation
                self?.downloadQueue?.addOperation(downloadOperation)
            }
        })
        return operation
    }
}
