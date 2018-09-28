//
//  WebPQueueManager.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class WebPQueueManager: NSObject {
    
    let maxQueueCount:Int = 3
    var requestQueueArray = [OperationQueue]()
    
    private static let instance = { () -> WebPQueueManager in
        return WebPQueueManager.init()
    }()
    
    private override init() {
        super.init()
    }
    
    class func shared() -> WebPQueueManager {
        return instance
    }
    
    
    //添加NSOperationQueue队列
    func addQueue(queue: OperationQueue) {
        objc_sync_enter(requestQueueArray)
        if(requestQueueArray.contains(queue)) {
            let index = requestQueueArray.index(of: queue) ?? 0
            requestQueueArray[index] = queue
        }else {
            requestQueueArray.append(queue)
            queue.addObserver(self, forKeyPath: "operations", options: NSKeyValueObservingOptions.new, context: nil)
        }
        processQueues()
        objc_sync_exit(requestQueueArray)
    }
    
    //取消指定NSOperationQueue队列
    func cancelQueue(queue: OperationQueue) {
        objc_sync_enter(requestQueueArray)
        if(requestQueueArray.contains(queue)) {
            queue.cancelAllOperations()
        }
        objc_sync_exit(requestQueueArray)
    }
    
    //刮起NSOperationQueue队列
    func suspendQueue(queue: OperationQueue, suspended:Bool) {
        objc_sync_enter(requestQueueArray)
        if(requestQueueArray.contains(queue)) {
            queue.isSuspended = suspended
        }
        objc_sync_exit(requestQueueArray)
    }
    
    //对当前并发的所有队列进行处理，保证正在执行的队列数量不超过最大执行的队列数
    func processQueues() {
        for (index, queue) in requestQueueArray.enumerated() {
            if(index < maxQueueCount) {
                suspendQueue(queue: queue, suspended: false)
            }else {
                suspendQueue(queue: queue, suspended: true)
            }
        }
    }
    
    //移除任务已经完成的队列，并更新当前正在执行的队列
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "operations") {
            let queue = object as! OperationQueue
            if(queue.operations.count == 0) {
                if let index = requestQueueArray.index(of: queue) {
                    requestQueueArray.remove(at: index)
                    processQueues()
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        for queue in requestQueueArray {
            queue.removeObserver(self, forKeyPath: "operations")
        }
    }
    
}
