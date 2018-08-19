//
//  RefreshControl.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/6.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

typealias OnRefresh = () -> Void

class RefreshControl: UIControl {
    var indicator: UIImageView = UIImageView.init(image: UIImage.init(named: "icon60LoadingMiddle"))
    var superView: UIScrollView?
    
    var refreshingType: RefreshingType = .RefreshHeaderStateIdle
    var onRefresh: OnRefresh?
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: -50, width: screenWidth, height: 50))
        self.addSubview(indicator)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.equalTo(25)
        }
        if superView == nil {
            superView = self.superview as? UIScrollView
            superView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let superView = self.superview as? UIScrollView {
                if superView.isDragging && refreshingType == .RefreshHeaderStateIdle && superView.contentOffset.y < -80 {
                    refreshingType = .RefreshHeaderStatePulling
                }
                if !superView.isDragging && refreshingType == .RefreshHeaderStatePulling && superView.contentOffset.y >= -50 {
                    startRefresh()
                    onRefresh?()
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func startRefresh() {
        if refreshingType != .RefreshHeaderStateRefreshing {
            refreshingType = .RefreshHeaderStateRefreshing
            var edgeInsets = superView?.contentInset
            edgeInsets?.top += 50
            superView?.contentInset = edgeInsets ?? .zero
            startAnim()
        }
    }
    
    func endRefresh() {
        if refreshingType != .RefreshHeaderStateIdle {
            refreshingType = .RefreshHeaderStateIdle
            var edgeInsets = superView?.contentInset
            edgeInsets?.top -= 50
            superView?.contentInset = edgeInsets ?? .zero
            stopAnim()
        }
    }
    
    func loadAll() {
        refreshingType = .RefreshHeaderStateAll
        self.isHidden = true
    }
    
    
    //animation
    func startAnim() {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: .pi * 2.0)
        rotationAnimation.duration = 1.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = MAXFLOAT
        indicator.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnim() {
        indicator.layer.removeAllAnimations()
    }
    
    deinit {
        superView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}
