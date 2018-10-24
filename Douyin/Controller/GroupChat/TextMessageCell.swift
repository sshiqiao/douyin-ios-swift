//
//  TextMessageCell.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
typealias OnMenuAction = (_ actionType:MenuActionType) -> Void
class TextMessageCell:UITableViewCell {
    
    var avatar = UIImageView.init(image: UIImage.init(named: "img_find_default"))
    var textView:UITextView = UITextView.init()
    var backgroundLayer = CAShapeLayer.init()
    var indicator = UIImageView.init(image: UIImage.init(named: "icon30WhiteSmall"))
    var tipIcon = UIImageView.init(image: UIImage.init(named: "icWarning"))
    var chat:GroupChat?
    var onMenuAction:OnMenuAction?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        initSubViews()
    }
    
    func initSubViews() {
        avatar.contentMode = .center
        avatar.contentMode = .scaleToFill
        self.addSubview(avatar)
        
        textView.textColor = TextMessageCell.attributes()[.foregroundColor] as? UIColor
        textView.font = TextMessageCell.attributes()[.font] as? UIFont
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = ColorClear
        textView.textContainerInset = UIEdgeInsets.init(top: USER_MSG_CORNER_RADIUS, left: USER_MSG_CORNER_RADIUS, bottom: USER_MSG_CORNER_RADIUS, right: USER_MSG_CORNER_RADIUS)
        textView.textContainer.lineFragmentPadding = 0
        textView.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(showMenu)))
        self.addSubview(textView)
        
        backgroundLayer = CAShapeLayer.init()
        backgroundLayer.zPosition = -1
        textView.layer.addSublayer(backgroundLayer)
        
        indicator.isHidden = true
        self.addSubview(indicator)
        
        tipIcon.isHidden = true
        self.addSubview(tipIcon)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.isHidden = true
        tipIcon.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var attributedString = NSMutableAttributedString.init(attributedString: textView.attributedText)
        attributedString.addAttributes(TextMessageCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        let size = attributedString.multiLineSize(width: MAX_USER_MSG_WIDTH)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.path = createBezierPath(cornerRadius: USER_MSG_CORNER_RADIUS, width: size.width, height: size.height).cgPath
        backgroundLayer.frame = CGRect.init(origin: .zero, size: CGSize.init(width: size.width + USER_MSG_CORNER_RADIUS * 2, height: size.height + USER_MSG_CORNER_RADIUS * 2))
        backgroundLayer.transform = CATransform3DIdentity
        if MD5_UDID == chat?.visitor?.udid {
            avatar.frame = CGRect.init(x: screenWidth - COMMON_MSG_PADDING - 30, y: COMMON_MSG_PADDING, width: 30, height: 30)
            textView.frame = CGRect.init(x: self.avatar.frame.minX - COMMON_MSG_PADDING - (size.width + USER_MSG_CORNER_RADIUS * 2), y: COMMON_MSG_PADDING, width: size.width + USER_MSG_CORNER_RADIUS * 2, height: size.height + USER_MSG_CORNER_RADIUS * 2)
            backgroundLayer.transform = CATransform3DMakeRotation(.pi, 0.0, 1.0, 0.0)
            backgroundLayer.fillColor = ColorThemeYellow.cgColor
        } else {
            avatar.frame = CGRect.init(x: COMMON_MSG_PADDING, y: COMMON_MSG_PADDING, width: 30, height: 30)
            textView.frame = CGRect.init(x: self.avatar.frame.maxX + COMMON_MSG_PADDING, y: COMMON_MSG_PADDING, width: size.width + USER_MSG_CORNER_RADIUS * 2, height: size.height + USER_MSG_CORNER_RADIUS * 2)
            backgroundLayer.fillColor = ColorWhite.cgColor
        }
        CATransaction.commit()
        indicator.snp.makeConstraints { make in
            make.top.equalTo(self.textView)
            make.right.equalTo(self.textView.snp.left).inset(-10)
            make.width.height.equalTo(15);
        }
        tipIcon.snp.makeConstraints { make in
            make.top.equalTo(self.textView);
            make.right.equalTo(self.textView.snp.left).inset(10);
            make.width.height.equalTo(15);
        }
    }
    
    func initData(chat:GroupChat) {
        self.chat = chat
        var attributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(TextMessageCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        textView.attributedText = attributedString
        if chat.isTemp {
            startAnim()
            if chat.isFailed {
                tipIcon.isHidden = false
            }
            if chat.isCompleted {
                stopAnim()
            }
        } else {
            stopAnim()
        }
        avatar.setImageWithURL(imageUrl: URL.init(string: chat.visitor?.avatar_thumbnail?.url ?? "")!) {[weak self] (image, error) in
            if error == nil {
                self?.avatar.image = image?.drawCircleImage()
            }
        }
    }
    
    func startAnim() {
        indicator.isHidden = false
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Float(CGFloat.pi * 2)
        rotationAnimation.duration = 1.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(MAXFLOAT)
        indicator.layer.add(rotationAnimation, forKey: nil)
    }
    
    func stopAnim() {
        indicator.isHidden = true
        indicator.layer.removeAllAnimations()
    }
    
    func createBezierPath(cornerRadius:CGFloat, width:CGFloat, height:CGFloat) -> UIBezierPath {
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.init(x: 0, y: cornerRadius))
        bezierPath.addArc(withCenter: CGPoint.init(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: -.pi / 2, clockwise: true)
        bezierPath.addLine(to: CGPoint.init(x: cornerRadius + width, y: 0))
        bezierPath.addArc(withCenter: CGPoint.init(x: cornerRadius + width, y: cornerRadius), radius: cornerRadius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        bezierPath.addLine(to: CGPoint.init(x: cornerRadius + width + cornerRadius, y: cornerRadius + height))
        bezierPath.addArc(withCenter: CGPoint.init(x: cornerRadius + width, y: cornerRadius + height), radius: cornerRadius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        bezierPath.addLine(to: CGPoint.init(x: cornerRadius + cornerRadius/4, y: cornerRadius + height + cornerRadius))
        bezierPath.addArc(withCenter: CGPoint.init(x: cornerRadius + cornerRadius/4, y: cornerRadius + height), radius: cornerRadius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
        bezierPath.addLine(to: CGPoint.init(x: cornerRadius/4, y: cornerRadius + cornerRadius/4))
        bezierPath.addArc(withCenter: CGPoint.init(x: 0, y: cornerRadius + cornerRadius/4), radius: cornerRadius/4, startAngle: 0, endAngle: -.pi/2, clockwise: false)
        return bezierPath
    }
    
    @objc func showMenu() {
        self.becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(menuFrame(), in: textView)
            let copy = UIMenuItem.init(title: "复制", action: #selector(onMenuCopy))
            if MD5_UDID == chat?.visitor?.udid {
                let delete = UIMenuItem.init(title: "删除", action: #selector(onMenuDelete))
                menu.menuItems = [copy, delete]
            } else {
                menu.menuItems = [copy]
            }
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    @objc func onMenuCopy() {
        onMenuAction?(.CopyAction)
    }
    
    @objc func onMenuDelete() {
        onMenuAction?(.DeleteAction)
        
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onMenuCopy) || action == #selector(onMenuDelete) {
            return true
        }
        return false
    }
    
    func menuFrame() -> CGRect {
        return CGRect.init(x: textView.bounds.midX - 60, y: 10, width: 120, height: 50)
    }
    
    static func attributes() -> [NSAttributedString.Key:Any] {
        return [.font: BigFont, .foregroundColor:ColorBlack]
    }
    
    static func cellHeight(chat:GroupChat) -> CGFloat {
        var attributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(TextMessageCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        let size = attributedString.multiLineSize(width: MAX_USER_MSG_WIDTH)
        return size.height + USER_MSG_CORNER_RADIUS * 2 + COMMON_MSG_PADDING * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
