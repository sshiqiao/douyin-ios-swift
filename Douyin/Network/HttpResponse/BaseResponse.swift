//
//  BaseResponse.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/2.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class BaseResponse: BaseModel {
    var code:Int?
    var message:String?
    var has_more:Int = 0
    var total_count:Int = 0
}
