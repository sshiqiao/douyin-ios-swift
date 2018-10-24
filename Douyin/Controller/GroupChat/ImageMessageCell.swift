//
//  ImageMessageCell.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class ImageMessageCell:UITableViewCell {
    
    var avatar = UIImageView.init(image: UIImage.init(named: "img_find_default"))
    var imageMsg:UIImageView = UIImageView.init()
    var progress = CircleProgress.init()
    var chat:GroupChat?
    var onMenuAction:OnMenuAction?
    
    var imageWidth:CGFloat = 0
    var imageHeight:CGFloat = 0
    var rectImage:UIImage?
    
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
        
        imageMsg.backgroundColor = ColorGray;
        imageMsg.contentMode = .scaleAspectFit;
        imageMsg.layer.cornerRadius = MSG_IMAGE_CORNOR_RADIUS;
        imageMsg.isUserInteractionEnabled = true;
        imageMsg.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(showMenu)))
        imageMsg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showPhotoView)))
        self.addSubview(imageMsg)
        
        progress = CircleProgress.init()
        self.addSubview(progress)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageMsg.image = nil
        progress.progress = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if MD5_UDID == chat?.visitor?.udid {
            avatar.frame = CGRect.init(x: screenWidth - COMMON_MSG_PADDING - 30, y: COMMON_MSG_PADDING, width: 30, height: 30)
        } else {
            avatar.frame = CGRect.init(x: COMMON_MSG_PADDING, y: COMMON_MSG_PADDING, width: 30, height: 30)
        }
        updateImageFrame()
        progress.snp.makeConstraints { make in
            make.center.equalTo(self.imageMsg)
            make.width.height.equalTo(50)
        }
    }
    
    func updateImageFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if MD5_UDID == chat?.visitor?.udid {
            imageMsg.frame = CGRect.init(x: self.avatar.frame.minX - COMMON_MSG_PADDING - imageWidth, y: COMMON_MSG_PADDING, width: imageWidth, height: imageHeight)
        } else {
            imageMsg.frame = CGRect.init(x: self.avatar.frame.maxX + COMMON_MSG_PADDING, y: COMMON_MSG_PADDING, width: imageWidth, height: imageHeight)
        }
        CATransaction.commit()
    }
    
    func initData(chat:GroupChat) {
        self.chat = chat
        imageWidth = ImageMessageCell.imageWidth(chat: chat)
        imageHeight = ImageMessageCell.imageHeight(chat: chat)
        
        rectImage = nil
        progress.isTipHidden = true
        if chat.picImage != nil {
            progress.isHidden = true
            rectImage = chat.picImage
            if let image = chat.picImage?.drawRoundedRectImage(cornerRadius: MSG_IMAGE_CORNOR_RADIUS, width: imageWidth, height: imageHeight) {
                imageMsg.image = image
                updateImageFrame()
            }
        } else {
            progress.isHidden = false
            imageMsg.setImageWithURL(imageUrl: URL.init(string: chat.pic_medium?.url ?? "")!, progress: {[weak self] percent in
                self?.progress.progress = percent
                }, completed: {[weak self] (image, error) in
                    if error == nil {
                        self?.chat?.picImage = image
                        self?.rectImage = image
                        self?.imageMsg.image = image?.drawRoundedRectImage(cornerRadius: MSG_IMAGE_CORNOR_RADIUS, width: self?.imageWidth ?? 0, height: self?.imageHeight ?? 0)
                        self?.updateImageFrame()
                        self?.progress.isHidden = true
                    } else {
                        self?.progress.isTipHidden = false
                    }
            })
        }
        avatar.setImageWithURL(imageUrl: URL.init(string: chat.visitor?.avatar_thumbnail?.url ?? "")!) {[weak self] (image, error) in
            if error == nil {
                self?.avatar.image = image?.drawCircleImage()
            }
        }
    }
    
    func updateUploadStatus(chat:GroupChat) {
        progress.isHidden = false
        progress.isTipHidden = true
        if chat.isTemp {
            progress.progress = chat.percent ?? 0
            if chat.isFailed {
                progress.isTipHidden = false
                return
            }
            if chat.isCompleted {
                progress.isHidden = true
                return
            }
        }
    }
    
    static func imageWidth(chat:GroupChat) -> CGFloat {
        var width:CGFloat = CGFloat(chat.pic_large?.width ?? 0)
        let height:CGFloat = CGFloat(chat.pic_large?.height ?? 0)
        let ratio:CGFloat = width/height
        if width > height {
            if width > MAX_MSG_IMAGE_WIDTH {
                width = MAX_MSG_IMAGE_WIDTH
            }
        } else {
            if height > MAX_MSG_IMAGE_HEIGHT {
                width = MAX_MSG_IMAGE_WIDTH*ratio
            }
        }
        return width
    }
    
    static func imageHeight(chat:GroupChat) -> CGFloat {
        let width:CGFloat = CGFloat(chat.pic_large?.width ?? 0)
        var height:CGFloat = CGFloat(chat.pic_large?.height ?? 0)
        let ratio:CGFloat = width/height
        if width > height {
            if width > MAX_MSG_IMAGE_WIDTH {
                height = MAX_MSG_IMAGE_WIDTH / ratio
            }
        } else {
            if height > MAX_MSG_IMAGE_HEIGHT {
                height = MAX_MSG_IMAGE_HEIGHT
            }
        }
        return height
    }
    
    @objc func showMenu() {
        self.becomeFirstResponder()
        if MD5_UDID == chat?.visitor?.udid {
            let menu = UIMenuController.shared
            if !menu.isMenuVisible {
                menu.setTargetRect(menuFrame(), in: imageMsg)
                let delete = UIMenuItem.init(title: "删除", action: #selector(onMenuDelete))
                menu.menuItems = [delete]
                menu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func showPhotoView() {
        PhotoView.init(chat?.pic_original?.url, rectImage).show()
    }
    
    @objc func onMenuDelete() {
        onMenuAction?(.DeleteAction)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onMenuDelete) {
            return true
        } else {
            return false
        }
    }
    
    func menuFrame() -> CGRect {
        return CGRect.init(x: self.imageWidth/2 - 60, y: 10, width: 120, height: 50)
    }
    
    static func cellHeight(chat:GroupChat) -> CGFloat {
        return self.imageHeight(chat: chat) + COMMON_MSG_PADDING * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
