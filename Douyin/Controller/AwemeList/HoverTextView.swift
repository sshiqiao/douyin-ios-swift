//
//  HoverTextView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation


protocol SendTextDelegate {
    func onSendText(text:String)
}

protocol HoverTextViewDelegate {
    func hoverTextViewStateChange(isHover:Bool)
}

class HoverTextView:UIView {
    
    var LEFT_INSET:CGFloat = 40
    var RIGHT_INSET:CGFloat = 100
    var TOP_BOTTOM_INSET:CGFloat = 15
    
    var textView:UITextView = UITextView.init()
    var delegate:SendTextDelegate?
    var hoverDelegate:HoverTextViewDelegate?
    
    var textHeight:CGFloat = 0
    var keyboardHeight:CGFloat = 0
    var placeHolderLabel:UILabel = UILabel.init()
    var editImageView:UIImageView = UIImageView.init(image: UIImage.init(named: "ic30Pen1"))
    var atImageView:UIImageView = UIImageView.init(image: UIImage.init(named: "ic30WhiteAt"))
    var sendImageView:UIImageView = UIImageView.init(image: UIImage.init(named: "ic30WhiteSend"))
    var splitLine:UIView = UIView.init()
    
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
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        
        keyboardHeight = safeAreaBottomHeight;
        
        textView.backgroundColor = ColorClear
        textView.clipsToBounds = false
        textView.textColor = ColorWhite
        textView.font = BigFont
        textView.returnKeyType = .send
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.init(top: TOP_BOTTOM_INSET, left: LEFT_INSET, bottom: TOP_BOTTOM_INSET, right: RIGHT_INSET)
        textHeight = textView.font?.lineHeight ?? 0
        
        placeHolderLabel.frame = CGRect.init(x:LEFT_INSET, y:0, width:screenWidth - LEFT_INSET - RIGHT_INSET, height:50)
        placeHolderLabel.text = "有爱评论，说点儿好听的~"
        placeHolderLabel.textColor = ColorWhiteAlpha40
        placeHolderLabel.font = BigFont
        textView.addSubview(placeHolderLabel)
//        textView.setValue(placeHolderLabel, forKey: "_placeholderLabel")
        
        editImageView.frame = CGRect.init(x: 0, y: 0, width: 40, height: 50)
        editImageView.contentMode = .center
        textView.addSubview(editImageView)
        
        atImageView.frame = CGRect.init(x: screenWidth - 50, y: 0, width: 50, height: 50)
        atImageView.contentMode = .center
        textView.addSubview(atImageView)
        
        sendImageView.frame = CGRect.init(x: screenWidth, y: 0, width: 50, height: 50)
        sendImageView.contentMode = .center
        sendImageView.isUserInteractionEnabled = true
        sendImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onSend)))
        textView.addSubview(sendImageView)
        
        splitLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 0.5))
        splitLine.backgroundColor = ColorWhiteAlpha40
        textView.addSubview(splitLine)
        
        textView.delegate = self
        self.addSubview(textView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = self.superview?.bounds ?? .zero
        updateViewFrameAndState()
    }
    
    func updateViewFrameAndState() {
        updateIconState()
        updateRightViewsFrame()
        updateTextViewFrame()
    }
    
    func updateTextViewFrame() {
        let textViewHeight = keyboardHeight > safeAreaBottomHeight ? textHeight + 2*TOP_BOTTOM_INSET : (textView.font?.lineHeight ?? 0) + 2*TOP_BOTTOM_INSET
        self.textView.frame = CGRect.init(x: 0, y: screenHeight - keyboardHeight - textViewHeight, width: screenWidth, height: textViewHeight)
    }
    
    func updateRightViewsFrame() {
        var originX = screenWidth
        originX -= keyboardHeight > safeAreaBottomHeight ? 50 : (textView.text.count > 0 ? 50 : 0)
        UIView.animate(withDuration: 0.25) {
            self.sendImageView.frame = CGRect.init(x: originX, y: 0, width: 50, height: 50)
            self.atImageView.frame = CGRect.init(x: self.sendImageView.frame.minX - 50, y: 0, width: 50, height: 50)
        }
    }
    
    func updateIconState() {
        editImageView.image = keyboardHeight > safeAreaBottomHeight ? UIImage.init(named: "ic90Pen1") : (textView.text.count > 0 ? UIImage.init(named: "ic90Pen1") : UIImage.init(named: "ic30Pen1"))
        atImageView.image = keyboardHeight > safeAreaBottomHeight ? UIImage.init(named: "ic90WhiteAt") : (textView.text.count > 0 ? UIImage.init(named: "ic90WhiteAt") : UIImage.init(named: "ic30WhiteAt"))
        sendImageView.image = textView.text.count > 0 ? UIImage.init(named: "ic30RedSend") : UIImage.init(named: "ic30WhiteSend")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HoverTextView {
    
    @objc func keyboardWillShow(notification:Notification) {
        self.backgroundColor = ColorBlackAlpha40
        keyboardHeight = notification.keyBoardHeight()
        updateViewFrameAndState()
        hoverDelegate?.hoverTextViewStateChange(isHover: true)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.backgroundColor = ColorClear
        keyboardHeight = safeAreaBottomHeight
        updateViewFrameAndState()
        hoverDelegate?.hoverTextViewStateChange(isHover: false)
    }
}

extension HoverTextView:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let attributedText = NSMutableAttributedString.init(attributedString: textView.attributedText)
        textView.attributedText = attributedText
        if !textView.hasText {
            placeHolderLabel.isHidden = false
            textHeight = textView.font?.lineHeight ?? 0
        } else {
            placeHolderLabel.isHidden = true
            textHeight = attributedText.multiLineSize(width: screenWidth - LEFT_INSET - RIGHT_INSET).height
        }
        updateViewFrameAndState()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSend()
            return false
        }
        return true
    }
}

extension HoverTextView {
    @objc func onSend() {
        delegate?.onSendText(text: textView.text)
        textView.text = ""
        textHeight = textView.font?.lineHeight ?? 0
        textView.resignFirstResponder()
    }
    
    @objc func handleGuesture(sender:UITapGestureRecognizer) {
        let point = sender.location(in: textView)
        if !(textView.layer.contains(point)) {
            textView.resignFirstResponder()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            if hitView?.backgroundColor == ColorClear {
                return nil
            }
        }
        return hitView
    }
}
