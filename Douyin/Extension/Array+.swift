//
//  Array+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/17.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
extension Array {
    mutating func removeAtIndexes (indexs:[Int]) -> () {
        for index in indexs.sorted(by: >) {
            self.remove(at: index)
        }
    }
}
