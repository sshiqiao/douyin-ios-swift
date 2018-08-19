//
//  UIImage+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/5.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

extension UIImage {
    
    func drawRoundedRectImage(cornerRadius:CGFloat, width:CGFloat, height:CGFloat) -> UIImage? {
        let size = CGSize.init(width: width, height: height)
        let rect = CGRect.init(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
        context?.clip()
        self.draw(in: rect)
        context?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    func drawCircleImage() -> UIImage? {
        let side = min(self.size.width, self.size.height)
        let size = CGSize.init(width: side, height: side)
        let rect = CGRect.init(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath.init(roundedRect: rect, cornerRadius: side).cgPath)
        context?.clip()
        self.draw(in: rect)
        context?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
}
