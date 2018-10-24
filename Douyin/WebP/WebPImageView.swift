//
//  WebPImageView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class WebPImageView: UIImageView {
    
    var displayLink: CADisplayLink?       //CADisplayLink用于更新画面
    var requestQueue = OperationQueue.init()     //用于解码剩余图片的NSOperationQueue
    var firstFrameQueue = OperationQueue.init()  //用于专门解码WebP第一帧画面的NSOperationQueue
    var time: TimeInterval  = 0           //用于记录每帧时间间隔
    var operationCount: Int = 0           //当前添加进队列的NSOperation数量
    
    //重写image的setter、getter方法
    private var _image: WebPImage?
    override var image: UIImage? {
        set {
            super.image = newValue
            _image = newValue as? WebPImage
            
            displayLink?.isPaused = true
            WebPQueueManager.shared().cancelQueue(queue: requestQueue)
            firstFrameQueue.cancelAllOperations()
            
            time = 0
            operationCount = 0
            displayLink?.isPaused = false

            decodeFrames()
        }
        get {
            return _image
        }
    }
    
    init() {
        super.init(frame:.zero)
        self.backgroundColor = ColorClear
        displayLink = CADisplayLink.init(target: self, selector: #selector(startAnimation(link:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        displayLink?.isPaused = true
        
        requestQueue.maxConcurrentOperationCount = 1
        requestQueue.qualityOfService = .utility
        
        firstFrameQueue.maxConcurrentOperationCount = 1
        firstFrameQueue.qualityOfService = .userInteractive
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = ColorClear
        displayLink = CADisplayLink.init(target: self, selector: #selector(startAnimation(link:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        displayLink?.isPaused = true
        
        requestQueue.maxConcurrentOperationCount = 1
        requestQueue.qualityOfService = .utility
        
        firstFrameQueue.maxConcurrentOperationCount = 1
        firstFrameQueue.qualityOfService = .userInteractive
    }
    
    //重写initWithImage方法
    override init(image: UIImage?) {
        super.init(image: image)
        self.image = image
        self.backgroundColor = ColorClear
        displayLink = CADisplayLink.init(target: self, selector: #selector(startAnimation(link:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        displayLink?.isPaused = true
        
        requestQueue.maxConcurrentOperationCount = 1
        requestQueue.qualityOfService = .utility
        
        firstFrameQueue.maxConcurrentOperationCount = 1
        firstFrameQueue.qualityOfService = .userInteractive
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //解码WebP格式动图
    func decodeFrames() {
        //在_firstFrameQueue中添加解码第一帧的任务
        let operation = WebPImageOperation.init(image: (image as? WebPImage) ?? WebPImage.init()) {[weak self] frame in
            DispatchQueue.main.async {
                self?.layer.contents = frame?.image?.cgImage ?? nil
            }
        }
        operationCount += 1
        firstFrameQueue.addOperation(operation)
        
        while (operationCount < (image as? WebPImage)?.frameCount ?? 0) {
            let operation = WebPImageOperation.init(image: (image as? WebPImage) ?? WebPImage.init()) {[weak self] frame in
                DispatchQueue.main.async {
                    self?.layer.setNeedsDisplay()
                }
            }
            operationCount += 1
            requestQueue.addOperation(operation)
        }
        WebPQueueManager.shared().addQueue(queue: requestQueue)
    }
    
    //CADisplayLink指定回调的方法
    @objc func startAnimation(link:CADisplayLink) {
        if (image as? WebPImage)?.isAllFrameDecoded() ?? false {
            self.layer.setNeedsDisplay()
        }
    }
    
    override func display(_ layer: CALayer) {
        if(time == 0) {
            self.layer.contents = (image as? WebPImage)?.curDisplayFrame?.image?.cgImage ?? nil
            (image as? WebPImage)?.incrementCurDisplayIndex()
        }
        
        time += displayLink?.duration ?? 0
        if time >= Double((image as? WebPImage)?.curDisplayFrameDuration() ?? 0) {
            time = 0
        }
    }
}

