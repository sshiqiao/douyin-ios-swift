//
//  Music.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class Music: BaseModel {
    var extra:String?
    var cover_large:Cover?
    var id:Int?
    var cover_thumb:Cover?
    var mid:String?
    var cover_hd:Cover?
    var author:String?
    var user_count:Int?
    var play_url:Play_url?
    var cover_medium:Cover?
    var id_str:String?
    var title:String?
    var offline_desc:String?
    var is_restricted:Bool?
    var schema_url:String?
    var source_platform:Int?
    var duration:Int?
    var status:Int?
    var is_original:Bool?
}

class Cover: BaseModel {
    var url_list = [String]()
    var uri:String?
}

class Play_url: BaseModel {
    var url_list = [String]()
    var uri:String?
}
