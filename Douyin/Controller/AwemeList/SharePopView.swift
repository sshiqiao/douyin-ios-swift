//
//  SharePopView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class SharePopView:UIView {
    
    let topIconsName = [
        "icon_profile_share_wxTimeline",
        "icon_profile_share_wechat",
        "icon_profile_share_qqZone",
        "icon_profile_share_qq",
        "icon_profile_share_weibo",
        "iconHomeAllshareXitong"]
    let topTexts = [
        "朋友圈",
        "微信好友",
        "QQ空间",
        "QQ好友",
        "微博",
        "更多分享"]
    let bottomIconsName = [
        "icon_home_allshare_report",
        "icon_home_allshare_download",
        "icon_home_allshare_copylink",
        "icon_home_all_share_dislike"]
    let bottomTexts = [
        "举报",
        "保存至相册",
        "复制链接",
        "不感兴趣"]
    
    var container = UIView.init()
    var cancel = UIButton.init()
    
    init() {
        super.init(frame: screenFrame)
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    
    func initSubView() {
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        container.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: 280 + safeAreaBottomHeight)
        container.backgroundColor = ColorBlackAlpha60
        self.addSubview(container)
        
        let rounded = UIBezierPath.init(roundedRect: container.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        container.layer.mask = shape
        
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
        visualEffectView.frame = self.bounds
        visualEffectView.alpha = 1.0
        container.addSubview(visualEffectView)
        
        let label = UILabel.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: 35)))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "分享到"
        label.textColor = ColorGray
        label.font = MediumFont
        container.addSubview(label)
        
        let itemWidth = 68
        let topScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 35, width: screenWidth, height: 90))
        topScrollView.contentSize = CGSize.init(width: itemWidth * topIconsName.count, height: 80)
        topScrollView.showsHorizontalScrollIndicator = false
        topScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 30)
        container.addSubview(topScrollView)
        
        for index in 0..<topIconsName.count {
            let item = ShareItem.init(frame: CGRect.init(x: 20 + itemWidth * index, y: 0, width: 48, height: 90))
            item.icon.image = UIImage.init(named: topIconsName[index])
            item.label.text = topTexts[index]
            item.tag = index
            item.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onShareItemTap(sender:))))
            item.startAnimation(delayTime: TimeInterval(Double(index) * 0.03))
            topScrollView.addSubview(item)
        }
        
        let bottomScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 135, width: screenWidth, height: 90))
        bottomScrollView.contentSize = CGSize.init(width: itemWidth * bottomIconsName.count, height: 80)
        bottomScrollView.showsHorizontalScrollIndicator = false
        bottomScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 30)
        container.addSubview(bottomScrollView)
        
        for index in 0..<bottomIconsName.count {
            let item = ShareItem.init(frame: CGRect.init(x: 20 + itemWidth * index, y: 0, width: 48, height: 90))
            item.icon.image = UIImage.init(named: bottomIconsName[index])
            item.label.text = bottomTexts[index]
            item.tag = index
            item.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onActionItemTap(sender:))))
            item.startAnimation(delayTime: TimeInterval(Double(index) * 0.03))
            bottomScrollView.addSubview(item)
        }
        
        cancel.frame = CGRect.init(x: 0, y: 230, width: screenWidth, height: 50 + safeAreaBottomHeight)
        cancel.titleEdgeInsets = UIEdgeInsets(top: -safeAreaBottomHeight, left: 0, bottom: 0, right: 0)
        cancel.setTitle("取消", for: .normal)
        cancel.setTitleColor(ColorWhite, for: .normal)
        cancel.titleLabel?.font = BigFont
        cancel.backgroundColor = ColorGrayLight
        container.addSubview(cancel)
        
        let rounded2 = UIBezierPath.init(roundedRect: cancel.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let shape2 = CAShapeLayer.init()
        shape2.path = rounded2.cgPath
        cancel.layer.mask = shape2
        cancel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
    }
    
    @objc func onShareItemTap(sender:UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            break
        default:
            break
        }
        UIApplication.shared.openURL(URL.init(string: "https://github.com/sshiqiao/douyin-ios-swift")!)
        dismiss()
    }
    
    @objc func onActionItemTap(sender:UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            break
        default:
            break
        }
        dismiss()
    }
    
    @objc func handleGuesture(sender:UITapGestureRecognizer) {
        var point = sender.location(in: container)
        if !(container.layer.contains(point)) {
            dismiss()
            return
        }
        point = sender.location(in: cancel)
        if cancel.layer.contains(point) {
            dismiss()
        }
    }
    
    func show() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.addSubview(self)
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            var frame = self.container.frame
            frame.origin.y = frame.origin.y - frame.size.height
            self.container.frame = frame
        }) { finshed in
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            var frame = self.container.frame
            frame.origin.y = frame.origin.y + frame.size.height
            self.container.frame = frame
        }) { finshed in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShareItem:UIView {
    
    var icon = UIImageView.init()
    var label = UILabel.init()
    init() {
        super.init(frame: .zero)
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView() {
        icon.contentMode = .scaleToFill
        icon.isUserInteractionEnabled = true
        self.addSubview(icon)
        
        label.text = "TEXT"
        label.textColor = ColorWhiteAlpha60
        label.font = MediumFont
        label.textAlignment = .center
        self.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(10)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self.icon.snp.bottom).offset(10)
        }
    }
    
    func startAnimation(delayTime:TimeInterval) {
        let originalFrame = self.frame
        self.frame = CGRect.init(origin: CGPoint.init(x: originalFrame.minX, y: 35), size: originalFrame.size)
        UIView.animate(withDuration: 0.9, delay: delayTime, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.frame = originalFrame
        }) { finished in
        }
    }
}
