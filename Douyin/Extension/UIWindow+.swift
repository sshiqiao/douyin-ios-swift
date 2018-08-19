//
//  UIWindow+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/5.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

extension UIWindow {
    static var tipsKey = "tipsKey"
    static var tips:UITextView? {
        get{
            return objc_getAssociatedObject(self, &UIWindow.tipsKey) as? UITextView
        }
        set {
            objc_setAssociatedObject(self, &UIWindow.tipsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    static var tapKey = "tapKey"
    static var tap:UITapGestureRecognizer? {
        get{
            return objc_getAssociatedObject(self, &UIWindow.tapKey) as? UITapGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &UIWindow.tapKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    static func showTips(text:String) {
        if tips != nil {
            dismiss()
        }
        Thread.sleep(forTimeInterval: 0.5)
        
        let window = UIApplication.shared.delegate?.window as? UIWindow
        let maxWidth:CGFloat = 200
        let maxHeight:CGFloat = window?.frame.size.height ?? 0 - 200
        let commonInset:CGFloat = 10
        
        let font = UIFont.systemFont(ofSize: 12)
        let string = NSMutableAttributedString.init(string: text)
        string.addAttributes([.font:font], range: NSRange.init(location: 0, length: string.length))
        
        let rect = string.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let size = CGSize.init(width: CGFloat(ceilf(Float(rect.size.width))), height: CGFloat(ceilf(rect.size.height < maxHeight ? Float(rect.size.height) : Float(maxHeight))))
        
        let textFrame = CGRect.init(x: (window?.frame.size.width ?? 0)/2 - size.width/2 - commonInset, y: (window?.frame.size.height ?? 0) - size.height/2 - commonInset - 100, width: size.width  + commonInset * 2, height: size.height + commonInset * 2)
        
        let textView = UITextView.init(frame: textFrame)
        textView.text = text
        textView.font = font
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.black
        textView.layer.cornerRadius  = 5
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = UIEdgeInsets.init(top: commonInset, left: commonInset, bottom: commonInset, right: commonInset)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handlerGuesture(sender:)))
        window?.addGestureRecognizer(tapGesture)
        
        window?.addSubview(textView)
        
        tips = textView
        tap = tapGesture
        
        self.perform(#selector(dismiss), with: nil, afterDelay: 2.0)
    }
    
    @objc static func handlerGuesture(sender: UIGestureRecognizer) {
        dismiss()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
    }
    
    @objc static func dismiss() {
        if let tapGesture = tap {
            let window = UIApplication.shared.delegate?.window as? UIWindow
            window?.removeGestureRecognizer(tapGesture)
        }
        UIView.animate(withDuration: 0.25, animations: {
            tips?.alpha = 0.0
        }) { finished in
            tips?.removeFromSuperview()
        }
    }
}
