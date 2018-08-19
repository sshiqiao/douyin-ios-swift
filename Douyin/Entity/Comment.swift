//
//  Comment.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class Comment: BaseModel {
    var cid:String?
    var status:Int?
    var text:String?
    var digg_count:Int?
    var create_time:Int?
    var reply_id:String?
    var aweme_id:String?
    var user_digged:Int?
    var text_extra = [Any]()
    var user_type:String?
    var user:User?
    var visitor:Visitor?
    
    var isTemp:Bool = false
    var taskId:Int?
}
