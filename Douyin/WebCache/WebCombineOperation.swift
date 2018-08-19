//
//  WebCombineOperation.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class WebCombineOperation:NSObject {
    
    //网络资源下载取消后的回调block
    var cancelBlock:WebDownloaderCancelBlock?
    
    //查询缓存NSOperation任务
    var cacheOperation:Operation?
    
    //下载网络资源任务
    var downloadOperation:WebDownloadOperation?
    
    //取消查询缓存NSOperation任务和下载资源WebDownloadOperation任务
    func cancel() {
        
        //取消查询缓存NSOperation任务
        if(cacheOperation != nil) {
            cacheOperation?.cancel()
            cacheOperation = nil
        }
        
        //取消下载资源WebDownloadOperation任务
        if(downloadOperation != nil) {
            downloadOperation?.cancel()
            downloadOperation = nil
        }
        
        //任务取消回调
        if(cancelBlock != nil) {
            cancelBlock?()
            cancelBlock = nil
        }
    }
}
