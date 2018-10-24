//
//  UserInfoHeader.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import SnapKit

let DEFAULT_ANIMATION_TIME:TimeInterval = 0.25

let AVATAE_TAG:Int = 1000
let SEND_MESSAGE_TAG:Int = 2000
let FOCUS_TAG:Int = 3000
let FOCUS_CANCEL_TAG:Int = 4000
let SETTING_TAG:Int = 5000
let GITHUB_TAG:Int = 6000

protocol UserInfoDelegate : NSObjectProtocol {
    func onUserActionTap (tag:Int)
}

class UserInfoHeader: UICollectionReusableView {
    
    var delegate:UserInfoDelegate?
    var isFollowed:Bool = false
    
    var containerView:UIView = UIView.init()
    var constellations = ["射手座","摩羯座","双鱼座","白羊座","水瓶座","金牛座","双子座","巨蟹座","狮子座","处女座","天秤座","天蝎座"]
    
    var avatar:UIImageView = UIImageView.init(image: UIImage.init(named: "img_find_default"))
    var avatarBackground:UIImageView = UIImageView.init()
    
    var sendMessage:UILabel = UILabel.init()
    var focusIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_titlebar_addfriend"))
    var settingIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_titlebar_whitemore"))
    var focusButton:UIButton = UIButton.init()
    
    var nickName:UILabel = UILabel.init()
    var douyinNum:UILabel = UILabel.init()
    var github:UIButton = UIButton.init()
    var brief:UILabel = UILabel.init()
    var genderIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "iconUserProfileGirl"))
    var constellation:UITextView = UITextView.init()
    var likeNum:UILabel = UILabel.init()
    var followNum:UILabel = UILabel.init()
    var followedNum:UILabel = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initAvatarBackground()
        
        containerView.frame = self.bounds
        self.addSubview(containerView)
        
        initAvatar()
        initActionsView()
        initInfoView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAvatarBackground() {
        avatarBackground.frame = self.bounds
        avatarBackground.clipsToBounds = true
        avatarBackground.image = UIImage.init(named: "img_find_default")
        avatarBackground.backgroundColor = ColorThemeGray
        avatarBackground.contentMode = .scaleAspectFill
        self.addSubview(avatarBackground)
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
        let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
        visualEffectView.frame = self.bounds
        visualEffectView.alpha = 1
        avatarBackground.addSubview(visualEffectView)
    }
    
    func initAvatar() {
        let avatarRadius:CGFloat = 45
        avatar.isUserInteractionEnabled = true
        avatar.tag = AVATAE_TAG
        avatar.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(avatar)
        
        let paddingLayer = CALayer.init()
        paddingLayer.frame = CGRect.init(x: 0, y: 0, width: avatarRadius * 2, height: avatarRadius * 2)
        paddingLayer.borderColor = ColorWhiteAlpha20.cgColor
        paddingLayer.borderWidth = 2
        paddingLayer.cornerRadius = avatarRadius
        avatar.layer.addSublayer(paddingLayer)
        
        avatar.snp.makeConstraints { make in
            make.top.equalTo(self).offset(25 + 44 + statusBarHeight)
            make.left.equalTo(self).offset(15)
            make.width.height.equalTo(avatarRadius * 2)
        }
    }
    
    func initActionsView() {
        settingIcon.contentMode = .center
        settingIcon.layer.backgroundColor = ColorWhiteAlpha20.cgColor
        settingIcon.layer.cornerRadius = 2
        settingIcon.tag = SETTING_TAG
        settingIcon.isUserInteractionEnabled = true
        settingIcon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(settingIcon)
        settingIcon.snp.makeConstraints { make in
            make.centerY.equalTo(self.avatar)
            make.right.equalTo(self).inset(15)
            make.width.height.equalTo(40)
        }
        
        focusIcon.contentMode = .center
        focusIcon.isUserInteractionEnabled = true
        focusIcon.clipsToBounds = true
        focusIcon.isHidden = !isFollowed
        focusIcon.layer.backgroundColor = ColorWhiteAlpha20.cgColor
        focusIcon.layer.cornerRadius = 2
        focusIcon.tag = FOCUS_CANCEL_TAG
        focusIcon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(focusIcon)
        focusIcon.snp.makeConstraints { make in
            make.centerY.equalTo(self.settingIcon)
            make.right.equalTo(self.settingIcon.snp.left).inset(-5)
            make.width.height.equalTo(40)
        }
        
        sendMessage.text = "发消息"
        sendMessage.textColor = ColorWhiteAlpha60
        sendMessage.textAlignment = .center
        sendMessage.font = MediumFont
        sendMessage.isHidden = !isFollowed
        sendMessage.layer.backgroundColor = ColorWhiteAlpha20.cgColor
        sendMessage.layer.cornerRadius = 2
        sendMessage.tag = SEND_MESSAGE_TAG
        sendMessage.isUserInteractionEnabled = true
        sendMessage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(sendMessage)
        sendMessage.snp.makeConstraints { make in
            make.centerY.equalTo(self.focusIcon)
            make.right.equalTo(self.focusIcon.snp.left).inset(-5)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        
        focusButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 0)
        focusButton.setTitle("关注", for: .normal)
        focusButton.setTitleColor(ColorWhite, for: .normal)
        focusButton.titleLabel?.font = MediumFont
        focusButton.isHidden = isFollowed
        focusButton.clipsToBounds = true
        focusButton.setImage(UIImage.init(named: "icon_personal_add_little"), for: .normal)
        focusButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -2, bottom: 0, right: 0)
        focusButton.layer.backgroundColor = ColorThemeRed.cgColor
        focusButton.layer.cornerRadius = 2
        focusButton.tag = FOCUS_TAG
        focusButton.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(focusButton)
        focusButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.settingIcon)
            make.right.equalTo(self.settingIcon.snp.left).inset(-5)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
    }
    
    func initInfoView() {
        nickName.text = "name"
        nickName.textColor = ColorWhite
        nickName.font = SuperBigBoldFont
        containerView.addSubview(nickName)
        nickName.snp.makeConstraints { make in
            make.top.equalTo(self.avatar.snp.bottom).offset(20)
            make.left.equalTo(self.avatar)
            make.right.equalTo(self.settingIcon)
        }
        
        douyinNum.text = "抖音号："
        douyinNum.textColor = ColorWhite
        douyinNum.font = SmallFont
        containerView.addSubview(douyinNum)
        douyinNum.snp.makeConstraints { make in
            make.top.equalTo(self.nickName.snp.bottom).offset(3)
            make.left.right.equalTo(self.nickName)
        }
        
        let arrow = UIImageView.init(image: UIImage.init(named: "icon_arrow"))
        containerView.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.right.equalTo(self.douyinNum)
            make.width.height.equalTo(12)
        }
        
        github.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 3, bottom: 0, right: 0)
        github.setTitle("Github主页", for: .normal)
        github.setTitleColor(ColorWhite, for: .normal)
        github.titleLabel?.font = SmallFont
        github.setImage(UIImage.init(named: "icon_github"), for: .normal)
        github.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -3, bottom: 0, right: 0)
        github.tag = GITHUB_TAG
        github.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        containerView.addSubview(github)
        github.snp.makeConstraints { make in
            make.centerY.equalTo(self.douyinNum)
            make.right.equalTo(arrow).inset(5)
            make.width.equalTo(92)
        }
        
        let splitLine = UIView.init()
        splitLine.backgroundColor = ColorWhiteAlpha20
        containerView.addSubview(splitLine)
        splitLine.snp.makeConstraints { make in
            make.top.equalTo(self.douyinNum.snp.bottom).offset(10)
            make.left.right.equalTo(self.nickName)
            make.height.equalTo(0.5)
        }
        
        brief.text = "本宝宝暂时还没想到个性的签名"
        brief.textColor = ColorWhiteAlpha60
        brief.font = SmallFont
        brief.numberOfLines = 0
        containerView .addSubview(brief)
        brief.snp.makeConstraints { make in
            make.top.equalTo(splitLine.snp.bottom).offset(10)
            make.left.right.equalTo(self.nickName)
        }
        
        genderIcon.layer.backgroundColor = ColorWhiteAlpha20.cgColor
        genderIcon.layer.cornerRadius = 9
        genderIcon.contentMode = .center
        containerView.addSubview(genderIcon)
        genderIcon.snp.makeConstraints { make in
            make.left.equalTo(self.nickName)
            make.top.equalTo(self.brief.snp.bottom).offset(8)
            make.height.equalTo(18)
            make.width.equalTo(22)
        }
        
        constellation.textColor = ColorWhite
        constellation.text = "座"
        constellation.font = SuperSmallFont
        constellation.isScrollEnabled = false
        constellation.isEditable = false
        constellation.textContainerInset = UIEdgeInsets.init(top: 3, left: 6, bottom: 3, right: 6)
        constellation.textContainer.lineFragmentPadding = 0
        constellation.layer.backgroundColor = ColorWhiteAlpha20.cgColor
        constellation.layer.cornerRadius = 9
        constellation.sizeToFit()
        containerView.addSubview(constellation)
        constellation.snp.makeConstraints { make in
            make.left.equalTo(self.genderIcon.snp.right).offset(5)
            make.top.height.equalTo(self.genderIcon)
        }
        
        likeNum.text = "0获赞"
        likeNum.textColor = ColorWhite
        likeNum.font = BigBoldFont
        containerView.addSubview(likeNum)
        likeNum.snp.makeConstraints { make in
            make.top.equalTo(self.genderIcon.snp.bottom).offset(15)
            make.left.equalTo(self.avatar)
        }
        
        followNum.text = "0关注"
        followNum.textColor = ColorWhite
        followNum.font = BigBoldFont
        containerView.addSubview(followNum)
        followNum.snp.makeConstraints { make in
            make.top.equalTo(self.likeNum)
            make.left.equalTo(self.likeNum.snp.right).offset(30)
        }
        
        followedNum.text = "0粉丝"
        followedNum.textColor = ColorWhite
        followedNum.font = BigBoldFont
        containerView.addSubview(followedNum)
        followedNum.snp.makeConstraints { make in
            make.top.equalTo(self.likeNum)
            make.left.equalTo(self.followNum.snp.right).offset(30)
        }
    }
    
    func initData(user:User) {
        
        avatar.setImageWithURL(imageUrl: URL.init(string: user.avatar_medium?.url_list.first ?? "")!, completed: {[weak self] (image, error) in
            self?.avatarBackground.image = image
            self?.avatar.image = image?.drawCircleImage()
        })
        
        nickName.text = user.nickname
        douyinNum.text = "抖音号:" + (user.short_id ?? "")
        if user.signature != "" {
            brief.text = user.signature
        }
        genderIcon.image = UIImage.init(named: user.gender == 0 ? "iconUserProfileBoy" : "iconUserProfileGirl")
        constellation.text = constellations[user.constellation ?? 0]
        likeNum.text = String.init(user.total_favorited ?? 0) + "获赞"
        followNum.text = String.init(user.following_count ?? 0) + "关注"
        followedNum.text = String.init(user.follower_count ?? 0) + "粉丝"
    }
    
    @objc func onTapAction(sender: UITapGestureRecognizer) {
        if(self.delegate != nil) {
            self.delegate?.onUserActionTap(tag: (sender.view?.tag)!)
        }
    }
    
}

//scroll action
extension UserInfoHeader {
    
    func overScrollAction(offsetY:CGFloat)  {
        //计算背景容器缩放比例
        let scaleRatio:CGFloat = abs(offsetY)/370.0
        //计算容器缩放后y方向的偏移量
        let overScaleHeight:CGFloat = (370.0 * scaleRatio)/2.0
        //缩放同时平移背景容器
        avatarBackground.transform = CGAffineTransform.init(scaleX: scaleRatio + 1.0, y: scaleRatio + 1.0).concatenating(CGAffineTransform.init(translationX: 0, y: -overScaleHeight))
    }
    
    func scrollToTopAction(offsetY:CGFloat) {
        let alphaRatio = offsetY/(370.0 - 44.0 - statusBarHeight)
        containerView.alpha = 1.0 - alphaRatio
    }
    
}

//animation
extension UserInfoHeader {
    
    func startFocusAnimation() {
        showSendMessageAnimation()
        showFollowedAnimation()
        showUnFollowedAnimation()
    }
    
    func showSendMessageAnimation() {
        if !isFollowed {
            focusIcon.isHidden = false
            sendMessage.isHidden = false
        }
        if isFollowed {
            focusButton.isHidden = false
        }
        focusButton.isUserInteractionEnabled = false
        focusIcon.isUserInteractionEnabled = false
        if isFollowed {
            UIView.animate(withDuration: DEFAULT_ANIMATION_TIME, animations: {
                self.sendMessage.alpha = 0
                var frame = self.sendMessage.frame
                frame.origin.x = frame.origin.x - 35
                self.sendMessage.frame = frame
            }) { finished in
                self.focusIcon.isHidden = self.isFollowed
                self.focusButton.isHidden = !self.isFollowed
                self.isFollowed = !self.isFollowed
                
                var frame = self.sendMessage.frame
                frame.origin.x = frame.origin.x + 35
                self.sendMessage.frame = frame
                
                self.focusButton.isUserInteractionEnabled = true
                self.focusIcon.isUserInteractionEnabled = true
            }
        } else {
            var frame = sendMessage.frame
            frame.origin.x = frame.origin.x - 35
            sendMessage.frame = frame
            UIView.animate(withDuration: DEFAULT_ANIMATION_TIME, animations: {
                self.sendMessage.alpha = 1.0
                var frame = self.sendMessage.frame
                frame.origin.x = frame.origin.x + 35
                self.sendMessage.frame = frame
            }) { finished in
                self.focusIcon.isHidden = self.isFollowed
                self.focusButton.isHidden = !self.isFollowed
                self.isFollowed = !self.isFollowed
                
                self.focusButton.isUserInteractionEnabled = true
                self.focusIcon.isUserInteractionEnabled = true
            }
        }
    }
    
    func showFollowedAnimation() {
        let animationGroup = CAAnimationGroup.init()
        animationGroup.duration = DEFAULT_ANIMATION_TIME
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        
        let layer = focusButton.layer
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = UIBezierPath.init(rect: CGRect.init(origin: .zero, size: focusButton.frame.size)).cgPath
        layer.mask = maskLayer
        
        let positionAnimation = CABasicAnimation.init()
        positionAnimation.keyPath = "position.x"
        if isFollowed {
            positionAnimation.fromValue = layer.frame.origin.x + layer.frame.size.width
            positionAnimation.toValue = layer.frame.origin.x + layer.frame.size.width * 0.5
        } else {
            positionAnimation.fromValue = layer.frame.origin.x + layer.frame.size.width*0.5
            positionAnimation.toValue = layer.frame.origin.x + layer.frame.size.width
        }
        
        let sizeAnimation = CABasicAnimation.init()
        sizeAnimation.keyPath = "bounds.size.width"
        if isFollowed {
            sizeAnimation.fromValue = 0
            sizeAnimation.toValue = layer.frame.size.width
        } else {
            sizeAnimation.fromValue = layer.frame.size.width
            sizeAnimation.toValue = 0
        }
        
        animationGroup.animations = [positionAnimation, sizeAnimation]
        layer.add(animationGroup, forKey: nil)
    }
    
    func showUnFollowedAnimation() {
        let animationGroup = CAAnimationGroup.init()
        animationGroup.duration = DEFAULT_ANIMATION_TIME
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        
        let layer = focusIcon.layer
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = UIBezierPath.init(rect: CGRect.init(origin: .zero, size: focusIcon.frame.size)).cgPath
        layer.mask = maskLayer
        
        let positionAnimation = CABasicAnimation.init()
        positionAnimation.keyPath = "position.x"
        if isFollowed {
            positionAnimation.fromValue = layer.frame.origin.x + layer.frame.size.width*0.5
            positionAnimation.toValue = layer.frame.origin.x - layer.frame.size.width
        } else {
            positionAnimation.fromValue = layer.frame.origin.x - layer.frame.size.width
            positionAnimation.toValue = layer.frame.origin.x + layer.frame.size.width*0.5
        }
        
        let sizeAnimation = CABasicAnimation.init()
        sizeAnimation.keyPath = "bounds.size.width"
        if isFollowed {
            sizeAnimation.fromValue = layer.frame.size.width
            sizeAnimation.toValue = 0
        } else {
            sizeAnimation.fromValue = 0
            sizeAnimation.toValue = layer.frame.size.width
        }
        
        animationGroup.animations = [positionAnimation, sizeAnimation]
        layer.add(animationGroup, forKey: nil)
    }
    
}
