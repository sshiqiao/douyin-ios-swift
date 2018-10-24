//
//  CircleTextView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

let SEPARATE_TEXT:String = "   "

class CircleTextView:UIView {
    
    var _text:String = ""
    var text:String {
        set {
            _text = newValue
            let size = newValue.singleLineSizeWithAttributeText(font: font)
            textWidth = size.width
            textHeight = size.height
            textLayerFrame = CGRect.init(origin: .zero, size: CGSize.init(width: textWidth * 3 + textSeparateWidth * 2, height: textHeight))
            translationX = textWidth + textSeparateWidth
            drawTextLayer()
            startAnimation()
        }
        get {
            return _text
        }
    }
    
    var _textColor:UIColor = ColorWhite
    var textColor:UIColor {
        set {
            _textColor = newValue
            textLayer.foregroundColor = newValue.cgColor
        }
        get {
            return _textColor
        }
    }
    
    var _font:UIFont = MediumFont
    var font:UIFont {
        set {
            _font = newValue
            let size = text.singleLineSizeWithAttributeText(font: newValue)
            textWidth = size.width
            textHeight = size.height
            textLayerFrame = CGRect.init(origin: .zero, size: CGSize.init(width: textWidth * 3 + textSeparateWidth * 2, height: textHeight))
            translationX = textWidth + textSeparateWidth
            drawTextLayer()
            startAnimation()
        }
        get {
            return _font
        }
    }
    
    var textLayer = CATextLayer.init()
    var maskLayer = CAShapeLayer.init()
    var textSeparateWidth:CGFloat = 0
    var textWidth:CGFloat = 0
    var textHeight:CGFloat = 0
    var textLayerFrame:CGRect = .zero
    var translationX:CGFloat = 0
    
    init() {
        super.init(frame: .zero)
        initSubLayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubLayer()
    }
    
    
    func initSubLayer() {
        textSeparateWidth = SEPARATE_TEXT.singleLineSizeWithText(font: font).width
        textLayer.alignmentMode = CATextLayerAlignmentMode.natural
        textLayer.truncationMode = CATextLayerTruncationMode.none
        textLayer.isWrapped = false
        textLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(textLayer)
        self.layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        textLayer.frame = CGRect.init(origin: CGPoint.init(x: 0, y: (self.bounds.height-textLayerFrame.height) / 2), size: textLayerFrame.size)
        maskLayer.frame = self.bounds
        maskLayer.path = UIBezierPath.init(rect: self.bounds).cgPath
        CATransaction.commit()
    }
    
    func drawTextLayer() {
        textLayer.foregroundColor = textColor.cgColor
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.string = text + SEPARATE_TEXT + text + SEPARATE_TEXT + text
    }
    
    func startAnimation() {
        
        let anim = CABasicAnimation.init()
        anim.keyPath = "transform.translation.x"
        anim.fromValue = self.bounds.origin.x
        anim.toValue = self.bounds.origin.x - translationX
        anim.duration = CFTimeInterval(textWidth * 0.035)
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        
        anim.fillMode = CAMediaTimingFillMode.forwards;
        anim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        
        textLayer.add(anim, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
