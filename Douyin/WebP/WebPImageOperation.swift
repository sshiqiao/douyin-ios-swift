//
//  WebPImageOperation.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

//解码完后的回调用的block
typealias WebPCompletedBlock = (_ frame:WebPFrame?) -> Void

//专门用于解码WebP画面的NSOperation子类
class WebPImageOperation: Operation {
    var completedBlock:WebPCompletedBlock?
    var image:WebPImage?
    
    var _executing:Bool = false  //指定_executing用于记录任务是否执行
    var _finished:Bool = false   //指定_finished用于记录任务是否完成
    
    //初始化数据
    init(image:WebPImage, completed:@escaping WebPCompletedBlock) {
        super.init()
        self.image = image
        self.completedBlock = completed
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
        
        //解码WebP当前索引对应的帧画面
        let frame = image?.decodeCurFrame()
        
        //由于上一步是耗时步骤，在真机上测试的时间为0.05-0.1s之间，所以在结束任务前再判断一次任务执行前是否取消了任务
        if(self.isCancelled) {
            done()
            return
        }
        completedBlock?(frame)
        done()
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
        }
    }
    
}
