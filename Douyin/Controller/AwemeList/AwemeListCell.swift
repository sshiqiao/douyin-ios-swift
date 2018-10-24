//
//  AwemeListCell.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/6.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import AVFoundation

let LIKE_BEFORE_TAP_ACTION:Int = 1000
let LIKE_AFTER_TAP_ACTION:Int = 2000
let COMMENT_TAP_ACTION:Int = 3000
let SHARE_TAP_ACTION:Int = 4000

typealias OnPlayerReady = () -> Void

class AwemeListCell: UITableViewCell {
    
    var container:UIView = UIView.init()
    var gradientLayer:CAGradientLayer = CAGradientLayer.init()
    var pauseIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_play_pause"))
    var playerStatusBar:UIView = UIView.init()
    var musicIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_home_musicnote3"))
    var singleTapGesture:UITapGestureRecognizer?
    var lastTapTime:TimeInterval = 0
    var lastTapPoint:CGPoint = .zero
    
    var aweme:Aweme?
    
    var playerView:AVPlayerView = AVPlayerView.init()
    var hoverTextView:HoverTextView = HoverTextView.init()
    
    var musicName = CircleTextView.init()
    var desc:UILabel = UILabel.init()
    var nickName:UILabel = UILabel.init()
    
    var avatar:UIImageView = UIImageView.init(image: UIImage.init(named: "img_find_default"))
    var focus = FocusView.init()
    var musicAlum = MusicAlbumView.init()
    
    var share:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_home_share"))
    var comment:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_home_comment"))
    
    var favorite = FavoriteView.init()
    
    var shareNum:UILabel = UILabel.init()
    var commentNum:UILabel = UILabel.init()
    var favoriteNum:UILabel = UILabel.init()
    
    var onPlayerReady:OnPlayerReady?
    var isPlayerReady:Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        lastTapTime = 0
        lastTapPoint = .zero
        initSubViews()
    }
    
    func initSubViews() {
        playerView.delegate = self
        self.contentView.addSubview(playerView)

        self.contentView.addSubview(container)

        singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:)))
        container.addGestureRecognizer(singleTapGesture!)

        gradientLayer.colors = [ColorClear.cgColor, ColorBlackAlpha20.cgColor, ColorBlackAlpha40.cgColor]
        gradientLayer.locations = [0.3, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.0, y: 1.0)
        container.layer.addSublayer(gradientLayer)

        pauseIcon.contentMode = .center
        pauseIcon.layer.zPosition = 3
        pauseIcon.isHidden = true
        container.addSubview(pauseIcon)
        
        hoverTextView.delegate = self
        hoverTextView.hoverDelegate = self
        self.contentView.addSubview(hoverTextView)
        
        playerStatusBar.backgroundColor = ColorWhite
        playerStatusBar.isHidden = true
        container.addSubview(playerStatusBar)
        
        musicIcon.contentMode = .center
        container.addSubview(musicIcon)
        
        musicName.textColor = ColorWhite
        musicName.font = MediumFont
        container.addSubview(musicName)
        
        desc.numberOfLines = 0
        desc.textColor = ColorWhiteAlpha80
        desc.font = MediumFont
        container.addSubview(desc)
        
        nickName.textColor = ColorWhite
        nickName.font = BigBoldFont
        container.addSubview(nickName)
        
        container.addSubview(musicAlum)
        
        share.contentMode = .center
        share.isUserInteractionEnabled = true
        share.tag = SHARE_TAP_ACTION
        share.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:))))
        container.addSubview(share)
        
        shareNum.text = "0"
        shareNum.textColor = ColorWhite
        shareNum.font = SmallFont
        container.addSubview(shareNum)
        
        comment.contentMode = .center
        comment.isUserInteractionEnabled = true
        comment.tag = COMMENT_TAP_ACTION
        comment.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:))))
        container.addSubview(comment)
        
        commentNum.text = "0"
        commentNum.textColor = ColorWhite
        commentNum.font = SmallFont
        container.addSubview(commentNum)
        
        container.addSubview(favorite)
        
        favoriteNum.text = "0"
        favoriteNum.textColor = ColorWhite
        favoriteNum.font = SmallFont
        container.addSubview(favoriteNum)
        
        let avatarRadius:CGFloat = 25
        avatar.layer.cornerRadius = avatarRadius
        avatar.layer.borderColor = ColorWhiteAlpha80.cgColor
        avatar.layer.borderWidth = 1
        container.addSubview(avatar)
        
        container.addSubview(focus)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isPlayerReady = false
        playerView.cancelLoading()
        pauseIcon.isHidden = true
        
        hoverTextView.textView.text = ""
        avatar.image = UIImage.init(named: "img_find_default")
        
        musicAlum.resetView()
        favorite.resetView()
        focus.resetView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = self.bounds
        pauseIcon.frame = CGRect.init(x: self.bounds.midX - 50, y: self.bounds.midY - 50, width: 100, height: 100)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = CGRect.init(x: 0, y: self.bounds.height - 500, width: self.bounds.width, height: 500)
        CATransaction.commit()

        playerStatusBar.frame = CGRect.init(x: self.bounds.midX - 0.5, y: self.bounds.maxY - 49.5 - safeAreaBottomHeight, width: 1.0, height: 1)
        
        musicIcon.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.bottom.equalTo(self).inset(60 + safeAreaBottomHeight)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }

        musicName.snp.makeConstraints { make in
            make.left.equalTo(self.musicIcon.snp.right)
            make.centerY.equalTo(self.musicIcon)
            make.width.equalTo(screenWidth/2)
            make.height.equalTo(20)
        }
        desc.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self.musicIcon.snp.top).inset(-5)
            make.width.lessThanOrEqualTo(screenWidth / 5 * 3)
        }
        nickName.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self.desc.snp.top).inset(-5)
            make.width.lessThanOrEqualTo(screenWidth / 4 * 3 + 30)
        }
        musicAlum.snp.makeConstraints { make in
            make.bottom.equalTo(self.musicName)
            make.right.equalTo(self).inset(10)
            make.width.height.equalTo(50)
        }
        share.snp.makeConstraints { make in
            make.bottom.equalTo(self.musicAlum.snp.top).inset(-50)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(50)
            make.height.equalTo(45)
        }
        shareNum.snp.makeConstraints { make in
            make.top.equalTo(self.share.snp.bottom);
            make.centerX.equalTo(self.share);
        }
        comment.snp.makeConstraints { make in
            make.bottom.equalTo(self.share.snp.top).inset(-25);
            make.right.equalTo(self).inset(10);
            make.width.equalTo(50);
            make.height.equalTo(45);
        }
        commentNum.snp.makeConstraints { make in
            make.top.equalTo(self.comment.snp.bottom);
            make.centerX.equalTo(self.comment);
        }
        favorite.snp.makeConstraints { make in
            make.bottom.equalTo(self.comment.snp.top).inset(-25);
            make.right.equalTo(self).inset(10);
            make.width.equalTo(50);
            make.height.equalTo(45);
        }
        favoriteNum.snp.makeConstraints { make in
            make.top.equalTo(self.favorite.snp.bottom);
            make.centerX.equalTo(self.favorite);
        }
        let avatarRadius:CGFloat = 25;
        avatar.snp.makeConstraints { make in
            make.bottom.equalTo(self.favorite.snp.top).inset(-35);
            make.right.equalTo(self).inset(10);
            make.width.height.equalTo(avatarRadius*2);
        }
        focus.snp.makeConstraints { make in
            make.centerX.equalTo(self.avatar);
            make.centerY.equalTo(self.avatar.snp.bottom);
            make.width.height.equalTo(24);
        }
    }
    
    func initData(aweme:Aweme) {
        self.aweme = aweme
        playerView.setPlayerSourceUrl(url: aweme.video?.play_addr?.url_list.first ?? "")
        nickName.text = aweme.author?.nickname
        desc.text = aweme.desc
        musicName.text = (aweme.music?.title ?? "") + "-" + (aweme.music?.author ?? "")
        favoriteNum.text = String.formatCount(count: aweme.statistics?.digg_count ?? 0)
        commentNum.text = String.formatCount(count: aweme.statistics?.comment_count ?? 0)
        shareNum.text = String.formatCount(count: aweme.statistics?.share_count ?? 0)
        
        musicAlum.album.setImageWithURL(imageUrl: URL.init(string: aweme.music?.cover_thumb?.url_list.first ?? "")!) { (image, error) in
            if error == nil {
                self.musicAlum.album.image = image?.drawCircleImage()
            }
        }
        avatar.setImageWithURL(imageUrl: URL.init(string: aweme.author?.avatar_thumb?.url_list.first ?? "")!) { (image, error) in
            if error == nil {
                self.avatar.image = image?.drawCircleImage()
            }
        }
    }
    
    func play() {
        playerView.play()
    }
    
    func pause() {
        playerView.pause()
    }
    
    func replay() {
        playerView.replay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//gesture
extension AwemeListCell {
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case COMMENT_TAP_ACTION:
            CommentsPopView.init(awemeId: aweme?.aweme_id ?? "").show()
            break
        case SHARE_TAP_ACTION:
            SharePopView.init().show()
            break
        default:
            //获取点击坐标，用于设置爱心显示位置
            let point = sender.location(in: container)
            //获取当前时间
            let time = CACurrentMediaTime()
            //判断当前点击时间与上次点击时间的时间间隔
            if (time - lastTapTime) > 0.25 {
                //推迟0.25秒执行单击方法
                self.perform(#selector(singleTapAction), with: nil, afterDelay: 0.25)
            } else {
                //取消执行单击方法
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(singleTapAction), object: nil)
                //执行连击显示爱心的方法
                showLikeViewAnim(newPoint: point, oldPoint: lastTapPoint)
            }
            //更新上一次点击位置
            lastTapPoint = point
            //更新上一次点击时间
            lastTapTime = time
            break
        }
    }
    
    @objc func singleTapAction() {
        if hoverTextView.isFirstResponder {
            hoverTextView.resignFirstResponder()
        } else {
            showPauseViewAnim(rate: playerView.rate())
            playerView.updatePlayerState()
        }
    }
}

//animation
extension AwemeListCell {
    func showPauseViewAnim(rate:CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.pauseIcon.alpha = 0.0
            }) { finished in
                self.pauseIcon.isHidden = true
            }
        } else {
            pauseIcon.isHidden = false
            pauseIcon.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
            pauseIcon.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.pauseIcon.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { finished in
            }
        }
    }
    
    func showLikeViewAnim(newPoint:CGPoint, oldPoint:CGPoint) {
        let likeImageView = UIImageView.init(image: UIImage.init(named: "icon_home_like_after"))
        var k = (oldPoint.y - newPoint.y) / (oldPoint.x - newPoint.x)
        k = abs(k) < 0.5 ? k : (k > 0 ? 0.5 : -0.5)
        let angle = .pi/4 * -k
        likeImageView.frame = CGRect.init(origin: newPoint, size: CGSize.init(width: 80, height: 80))
        likeImageView.transform = CGAffineTransform.init(scaleX: 0.8, y: 1.8).concatenating(CGAffineTransform.init(rotationAngle: angle))
        self.container.addSubview(likeImageView)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            likeImageView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0).concatenating(CGAffineTransform.init(rotationAngle: angle))
        }) { finished in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                likeImageView.transform = CGAffineTransform.init(scaleX: 3.0, y: 3.0).concatenating(CGAffineTransform.init(rotationAngle: angle))
                likeImageView.alpha = 0.0
            }, completion: { finished in
                likeImageView.removeFromSuperview()
            })
        }
    }
    
    func startLoadingPlayItemAnim(_ isStart:Bool = true) {
        if isStart {
            playerStatusBar.backgroundColor = ColorWhite
            playerStatusBar.isHidden = false
            playerStatusBar.layer.removeAllAnimations()
            
            let animationGroup = CAAnimationGroup.init()
            animationGroup.duration = 0.5
            animationGroup.beginTime = CACurrentMediaTime()
            animationGroup.repeatCount = .infinity
            animationGroup.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            let scaleAnim = CABasicAnimation.init()
            scaleAnim.keyPath = "transform.scale.x"
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue = 1.0 * screenWidth
            
            let alphaAnim = CABasicAnimation.init()
            alphaAnim.keyPath = "opacity"
            alphaAnim.fromValue = 1.0
            alphaAnim.toValue = 0.2
            
            animationGroup.animations = [scaleAnim, alphaAnim]
            playerStatusBar.layer.add(animationGroup, forKey: nil)
        } else {
            playerStatusBar.layer.removeAllAnimations()
            playerStatusBar.isHidden = true
        }
        
    }
}

extension AwemeListCell: SendTextDelegate, HoverTextViewDelegate {
    
    func onSendText(text: String) {
        if let aweme_id = aweme?.aweme_id {
            PostCommentRequest.postCommentText(aweme_id:aweme_id, text: text, success: { data in
                UIWindow.showTips(text: "评论成功")
            }, failure: { error in
                UIWindow.showTips(text: "评论失败")
            })
        }
    }
    
    func hoverTextViewStateChange(isHover: Bool) {
        container.alpha = isHover ? 0.0 : 1.0
    }
    
}

extension AwemeListCell: AVPlayerUpdateDelegate {
    
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            startLoadingPlayItemAnim()
            break
        case .readyToPlay:
            startLoadingPlayItemAnim(false)
            
            isPlayerReady = true
            musicAlum.startAnimation(rate: CGFloat(aweme?.rate ?? 0))
            onPlayerReady?()
            break
        case .failed:
            startLoadingPlayItemAnim(false)
            break
        }
    }
}
