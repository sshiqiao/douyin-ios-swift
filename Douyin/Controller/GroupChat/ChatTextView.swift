//
//  ChatTextView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import Photos

let EMOTION_TAG:Int = 1000
let PHOTO_TAG:Int = 2000

let LEFT_INSET:CGFloat = 15
let RIGHT_INSET:CGFloat = 85
let TOP_BOTTOM_INSET:CGFloat = 15

protocol ChatTextViewDelegate:NSObjectProtocol {
    func onSendText(text:String)
    func onSendImages(images:[UIImage])
    func onEditBoardHeightChange(height:CGFloat)
}
class ChatTextView:UIView {
    var container = UIView.init()
    var textView = UITextView.init()
    var editMessageType:ChatEditMessageType = .EditNoneMessage
    var delegate:ChatTextViewDelegate?
    var textHeight:CGFloat = 0
    @objc dynamic var containerBoardHeight:CGFloat = 0
    var placeHolderLabel = UILabel.init()
    var emotionBtn = UIButton.init()
    var photoBtn = UIButton.init()
    var visualEffectView = UIVisualEffectView.init()
    lazy var emotionSelector:EmotionSelector = {
        let emotionSelector = EmotionSelector.init()
        emotionSelector.delegate = self
        emotionSelector.addTextViewObserver(textView: textView)
        emotionSelector.isHidden = true
        container.addSubview(emotionSelector)
        return emotionSelector
    }()
    
    lazy var photoSelector:PhotoSelector = {
        let photoSelector = PhotoSelector.init()
        photoSelector.delegate = self
        photoSelector.isHidden = true
        container.addSubview(photoSelector)
        return photoSelector
    }()
    
    init() {
        super.init(frame: screenFrame)
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    func initSubView() {
        self.backgroundColor = ColorClear
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        container.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: 0)
        container.backgroundColor = ColorThemeGrayDark
        self.addSubview(container)
        
        containerBoardHeight = safeAreaBottomHeight
        
        textView.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: 0)
        textView.backgroundColor = ColorClear
        textView.clipsToBounds = true
        textView.textColor = ColorWhite
        textView.font = BigFont
        textView.returnKeyType = .send
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainerInset = UIEdgeInsets.init(top: TOP_BOTTOM_INSET, left: LEFT_INSET, bottom: TOP_BOTTOM_INSET, right: RIGHT_INSET)
        textView.textContainer.lineFragmentPadding = 0
        textHeight = textView.font?.lineHeight ?? 0
        
        placeHolderLabel.frame = CGRect.init(x:LEFT_INSET, y:0, width:screenWidth - LEFT_INSET - RIGHT_INSET, height:50)
        placeHolderLabel.text = "发送消息..."
        placeHolderLabel.textColor = ColorGray
        placeHolderLabel.font = BigFont
        textView.addSubview(placeHolderLabel)
//        textView.setValue(placeHolderLabel, forKey: "_placeholderLabel")
        
        textView.delegate = self
        container.addSubview(textView)
        
        emotionBtn.tag = EMOTION_TAG
        emotionBtn.setImage(UIImage.init(named: "baseline_emotion_white"), for: .normal)
        emotionBtn.setImage(UIImage.init(named: "outline_keyboard_grey"), for: .selected)
        emotionBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        textView.addSubview(emotionBtn)
        
        photoBtn.tag = PHOTO_TAG;
        photoBtn.setImage(UIImage.init(named: "outline_photo_white"), for: .normal)
        photoBtn.setImage(UIImage.init(named: "outline_photo_red"), for: .selected)
        photoBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        textView.addSubview(photoBtn)
        
        self.addObserver(self, forKeyPath: "containerBoardHeight", options: [.initial,.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "containerBoardHeight" {
            if containerBoardHeight == safeAreaBottomHeight {
                container.backgroundColor = ColorThemeGrayDark
                textView.textColor = ColorWhite
                
                emotionBtn.setImage(UIImage.init(named: "baseline_emotion_white"), for: .normal)
                photoBtn.setImage(UIImage.init(named: "outline_photo_white"), for: .normal)
            } else {
                container.backgroundColor = ColorWhite
                textView.textColor = ColorBlack
                
                emotionBtn.setImage(UIImage.init(named: "baseline_emotion_grey"), for: .normal)
                photoBtn.setImage(UIImage.init(named: "outline_photo_grey"), for: .normal)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateContainerFrame()
        
        photoBtn.frame = CGRect.init(x: screenWidth - 50, y: 0, width: 50, height: 50)
        emotionBtn.frame = CGRect.init(x: screenWidth - 85, y: 0, width: 50, height: 50)
        
        let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        container.layer.mask = shape
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            if editMessageType == .EditNoneMessage {
                return nil
            }
        }
        return hitView
    }
    
    func updateContainerFrame() {
        let textViewHeight = containerBoardHeight > safeAreaBottomHeight ? textHeight + 2*TOP_BOTTOM_INSET : BigFont.lineHeight + 2*TOP_BOTTOM_INSET
        textView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: textViewHeight)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.container.frame = CGRect.init(x: 0, y: screenHeight - self.containerBoardHeight - textViewHeight, width: screenWidth, height: self.containerBoardHeight + textViewHeight)
            self.delegate?.onEditBoardHeightChange(height: self.container.frame.height)
        }) { finished in
        }
    }
    
    func updateSelectorFrame(animated:Bool) {
        let textViewHeight = containerBoardHeight > 0 ? textHeight + 2*TOP_BOTTOM_INSET : BigFont.lineHeight + 2*TOP_BOTTOM_INSET;
        if animated {
            switch (self.editMessageType) {
            case .EditEmotionMessage:
                self.emotionSelector.isHidden = false
                self.emotionSelector.frame = CGRect.init(x: 0, y: textViewHeight + self.containerBoardHeight, width: screenWidth, height: self.containerBoardHeight)
                break
            case .EditPhotoMessage:
                self.photoSelector.isHidden = false
                self.photoSelector.frame = CGRect.init(x: 0, y: textViewHeight + self.containerBoardHeight, width: screenWidth, height: self.containerBoardHeight)
                break
            default:
                break
            }
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            switch (self.editMessageType) {
            case .EditEmotionMessage:
                self.emotionSelector.frame = CGRect.init(x:0, y:textViewHeight, width:screenWidth, height:self.containerBoardHeight)
                self.photoSelector.frame = CGRect.init(x:0, y:textViewHeight + self.containerBoardHeight, width:screenWidth,  height:self.containerBoardHeight)
                break
            case .EditPhotoMessage:
                self.photoSelector.frame = CGRect.init(x:0, y:textViewHeight,width:screenWidth, height:self.containerBoardHeight);
                self.emotionSelector.frame = CGRect.init(x:0, y:textViewHeight + self.containerBoardHeight, width:screenWidth, height:self.containerBoardHeight)
                break
            default:
                self.photoSelector.frame = CGRect.init(x:0, y:textViewHeight + self.containerBoardHeight, width:screenWidth,  height:self.containerBoardHeight)
                self.emotionSelector.frame = CGRect.init(x:0, y:textViewHeight + self.containerBoardHeight, width:screenWidth,  height:self.containerBoardHeight)
                break
            }
        }) { finished in
            switch (self.editMessageType) {
            case .EditEmotionMessage:
                self.photoSelector.isHidden = true
                break;
            case .EditPhotoMessage:
                self.emotionSelector.isHidden = true
                break;
            default:
                self.photoSelector.isHidden = true
                self.emotionSelector.isHidden = true
                break;
            }
        }
    }
    
    func hideContainerBoard() {
        editMessageType = .EditNoneMessage;
        containerBoardHeight = safeAreaBottomHeight
        updateContainerFrame()
        updateSelectorFrame(animated: true)
        textView.resignFirstResponder()
        emotionBtn.isSelected = false
        photoBtn.isSelected = false
    }
    
    func show() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.addSubview(self)
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
    deinit {
        emotionSelector.removeTextViewObserver(textView:textView)
        self.removeObserver(self, forKeyPath: "containerBoardHeight")
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatTextView {
    @objc func keyboardWillShow(notification:Notification) {
        editMessageType = .EditTextMessage
        emotionBtn.isSelected = false
        photoBtn.isSelected = false
        containerBoardHeight = notification.keyBoardHeight()
        updateContainerFrame()
        updateSelectorFrame(animated: true)
    }
}

extension ChatTextView:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let attributedString = NSMutableAttributedString.init(attributedString: textView.attributedText)
        if !textView.hasText {
            placeHolderLabel.isHidden = false
            textHeight = textView.font?.lineHeight ?? 0
        } else {
            placeHolderLabel.isHidden = true
            textHeight = attributedString.multiLineSize(width: screenWidth - LEFT_INSET - RIGHT_INSET).height
        }
        updateContainerFrame()
        updateSelectorFrame(animated: false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSend()
            return false
        }
        return true
    }
}

extension ChatTextView:UIGestureRecognizerDelegate {    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.superview?.classForCoder)!).contains("EmotionCell") || NSStringFromClass((touch.view?.superview?.classForCoder)!).contains("PhotoCell") {
            return false
        } else {
            return true
        }
    }
    
    @objc func handleGuesture(sender:UITapGestureRecognizer) {
        let point = sender.location(in: container)
        if !(container.layer.contains(point)) {
            hideContainerBoard()
        } else {
            switch sender.view?.tag {
            case EMOTION_TAG:
                emotionBtn.isSelected = !emotionBtn.isSelected
                photoBtn.isSelected = false
                if emotionBtn.isSelected {
                    editMessageType = .EditEmotionMessage
                    containerBoardHeight = EMOTION_SELECTOR_HEIGHT
                    updateContainerFrame()
                    updateSelectorFrame(animated: true)
                    textView.resignFirstResponder()
                } else {
                    editMessageType = .EditTextMessage
                    textView.becomeFirstResponder()
                }
                break
            case PHOTO_TAG:
                let status = PHPhotoLibrary.authorizationStatus()
                if status == .authorized {
                    DispatchQueue.main.async {[weak self] in
                        self?.photoBtn.isSelected = !(self?.photoBtn.isSelected)!
                        self?.emotionBtn.isSelected = false
                        if (self?.photoBtn.isSelected)! {
                            self?.editMessageType = .EditPhotoMessage
                            self?.containerBoardHeight = PHOTO_SELECTOR_HEIGHT
                            self?.updateContainerFrame()
                            self?.updateSelectorFrame(animated: true)
                            self?.textView.resignFirstResponder()
                        } else {
                            self?.hideContainerBoard()
                        }
                    }
                } else {
                    UIWindow.showTips(text: "请在设置中开启图库读取权限")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                        UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
                    })
                }
                break
            default:
                break
            }
        }
    }
}

extension ChatTextView:EmotionSelectorDelegate {
    
    func onDelete() {
        textView.deleteBackward()
    }
    
    func onSend() {
        let attributedString = NSMutableAttributedString.init(attributedString: textView.attributedText)
        let text = EmotionHelper.emotionToString(str: attributedString)
        if delegate != nil {
            if textView.hasText {
                delegate?.onSendText(text: text.string)
                textView.text = ""
                textHeight = textView.font?.lineHeight ?? 0
                updateContainerFrame()
                updateSelectorFrame(animated: false)
            } else {
                hideContainerBoard()
                UIWindow.showTips(text: "请输入文字")
            }
        }
    }
    
    func onSelect(emotionKey: String) {
        placeHolderLabel.isHidden = true
        
        let location = textView.selectedRange.location
        textView.attributedText = EmotionHelper.insertEmotion(str: textView.attributedText, index: location, key: emotionKey)
        textView.selectedRange = NSRange.init(location: location + 1, length: 0)
        textHeight = textView.attributedText.multiLineSize(width: screenWidth - LEFT_INSET - RIGHT_INSET).height
        updateContainerFrame()
        updateSelectorFrame(animated: false)
    }
    
}

extension ChatTextView:PhotoSelectorDelegate {
    
    func onSend(images: [UIImage]) {
        delegate?.onSendImages(images: images)
    }
    
}
