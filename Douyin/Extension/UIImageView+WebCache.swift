//
//  UIImageView+WebCache.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

typealias WebImageProgressBlock = (_ percent:Float) -> Void
typealias WebImageCompletedBlock = (_ image:UIImage?, _ error:Error?) -> Void
typealias WebImageCanceledBlock = () -> Void


extension UIImageView {
    static var operationKey = "operationKey"
    var operation:WebCombineOperation? {
        get{
            return objc_getAssociatedObject(self, &UIImageView.operationKey) as? WebCombineOperation
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.operationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setImageWithURL(imageUrl:URL, completed: WebImageCompletedBlock?) {
        self.setImageWithURL(imageUrl: imageUrl, progress: nil, completed: completed, cancel: nil)
    }
    
    func setImageWithURL(imageUrl:URL, progress:WebImageProgressBlock?, completed: WebImageCompletedBlock?) {
        self.setImageWithURL(imageUrl: imageUrl, progress: progress, completed: completed, cancel: nil)
    }
    
    func setImageWithURL(imageUrl:URL, progress:WebImageProgressBlock?, completed: WebImageCompletedBlock?, cancel:WebImageCanceledBlock?) {
        self.cancelOperation()
        operation = WebDownloader.shared().dowload(url: imageUrl, progress: { (receivedSize, expectedSize) in
            DispatchQueue.main.async {
                progress?(Float(receivedSize)/Float(expectedSize))
            }
        }, completed: { (data, error, finished) in
            var image:UIImage?
            if finished && data != nil {
                image = UIImage.init(data: data!)
            }
            DispatchQueue.main.async {
                completed?(image, error)
            }
        }) {
            cancel?()
        }
    }
    
    func setWebPImageWithURL(imageUrl:URL, completed: WebImageCompletedBlock?) {
        self.setWebPImageWithURL(imageUrl: imageUrl, progress: nil, completed: completed, cancel: nil)
    }
    
    func setWebPImageWithURL(imageUrl:URL, progress:WebImageProgressBlock?, completed: WebImageCompletedBlock?) {
        self.setWebPImageWithURL(imageUrl: imageUrl, progress: progress, completed: completed, cancel: nil)
    }
    
    func setWebPImageWithURL(imageUrl:URL, progress:WebImageProgressBlock?, completed:WebImageCompletedBlock?, cancel:WebImageCanceledBlock?) {
        self.cancelOperation()
        operation = WebDownloader.shared().dowload(url: imageUrl, progress: { (receivedSize, expectedSize) in
            DispatchQueue.main.async {
                progress?(Float(receivedSize/expectedSize))
            }
        }, completed: { (data, error, finished) in
            var image:WebPImage?
            if finished && data != nil {
                image = WebPImage.init(data: data!)
            }
            DispatchQueue.main.async {
                completed?(image, error)
            }
        }) {
            cancel?()
        }
    }
    
    func cancelOperation() {
        operation?.cancel()
    }
}
