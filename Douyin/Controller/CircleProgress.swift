//
//  CircleProgress.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/6.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class CircleProgress:UIControl {
    
    var _progress: Float = 0
    var progress: Float {
        set {
            _progress = newValue
            progressLayer.path = bezierPath(progress: newValue).cgPath
        }
        get {
            return _progress
        }
    }
    
    var _isTipHidden: Bool = true
    var isTipHidden: Bool {
        set {
            _isTipHidden = newValue
            tipIcon.isHidden = _isTipHidden
        }
        get {
            return _isTipHidden
        }
    }
    
    var progressLayer = CAShapeLayer.init()
    var tipIcon = UIImageView.init(image: UIImage.init(named: "icon_warn_white"))
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        self.initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView() {
        self.layer.backgroundColor = ColorBlackAlpha40.cgColor
        self.layer.borderColor = ColorWhiteAlpha80.cgColor
        self.layer.borderWidth = 1.0
        
        progressLayer.fillColor = ColorWhiteAlpha80.cgColor
        self.layer.addSublayer(progressLayer)
        
        tipIcon.contentMode = .center
        _isTipHidden = true
        self.addSubview(tipIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.width/2
        self.tipIcon.frame = self.bounds
    }
    
    func bezierPath(progress:Float) -> UIBezierPath {
        let center = CGPoint.init(x: self.bounds.midX, y: self.bounds.midY)
        let bezierPath = UIBezierPath.init(arcCenter: center, radius: self.frame.width/2 - 2, startAngle: -(.pi / 2) , endAngle: CGFloat(progress) * (.pi * 2) - (.pi / 2), clockwise: true)
        bezierPath.addLine(to: center)
        bezierPath.close()
        return bezierPath
    }
    
    func resetView() {
        progress = 0
        isTipHidden = true
    }
    
}
