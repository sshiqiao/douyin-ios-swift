//
//  PhotoView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/6.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class PhotoView: UIView {
    
    var progress:CircleProgress = CircleProgress.init()
    var container:UIView = UIView.init()
    var imageView:UIImageView = UIImageView.init()
    var _urlPath:String?
    var urlPath:String? {
        set {
            if newValue == nil && newValue != "" {
                return
            }
            _urlPath = newValue
            if let url = URL.init(string: _urlPath ?? "") {
                imageView.setImageWithURL(imageUrl: url, progress: { percent in
                    self.progress.progress = percent
                }, completed: {[weak self] (data, error) in
                    if error == nil {
                        self?.imageView.image = data
                        self?.progress.isHidden = true
                    } else {
                        self?.progress.isTipHidden = false
                    }
                }) 
            }
        }
        get {
            return _urlPath
        }
    }
    var _image:UIImage?
    var image:UIImage? {
        set {
            if newValue == nil {
                return
            }
            _image = newValue
            imageView.image = image
        }
        get {
            return _image
        }
    }
    
    init(_ urlPath:String? = "", _ image:UIImage? = UIImage.init()) {
        super.init(frame: screenFrame)
        self.urlPath = urlPath
        self.image = image
        self.initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubView()
    }
    
    func initSubView() {
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        container.frame = self.bounds
        container.backgroundColor = ColorBlack
        container.alpha = 0.0
        self.addSubview(container)
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        progress.center = self.center
        progress.isTipHidden = true
        imageView.addSubview(progress)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleGuesture(sender:UITapGestureRecognizer) {
        dismiss()
    }
    
    func show() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.windowLevel = UIWindowLevelStatusBar
        window?.addSubview(self)
        UIView.animate(withDuration: 0.15) {
            self.imageView.alpha = 1.0
            self.container.alpha = 1.0
        }
    }
    
    func dismiss() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.windowLevel = UIWindowLevelNormal
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear, animations: {
            self.imageView.alpha = 0.0
            self.container.alpha = 0.0
        }) { finished in
            self.removeFromSuperview()
        }
    }

}
