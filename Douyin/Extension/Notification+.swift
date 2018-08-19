//
//  Notification+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

extension Notification {
    
    func keyBoardHeight() -> CGFloat {
        if let userInfo = self.userInfo {
            if let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let size = value.cgRectValue.size
                let orientation = UIApplication.shared.statusBarOrientation
                return UIInterfaceOrientationIsLandscape(orientation) ? size.width : size.height
            }
        }
        return 0
    }
    
}
