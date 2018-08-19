//
//  Video.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class Video: BaseModel {
    var dynamic_cover:Cover?
    var play_addr_lowbr:Play_url?
    var width:Int?
    var ratio:String?
    var play_addr:Play_url?
    var cover:Cover?
    var height:Int?
    var bit_rate = [Bit_rate]()
    var origin_cover:Cover?
    var duration:Int?
    var download_addr:Download_addr?
    var has_watermark:Bool?
}

class Bit_rate: BaseModel {
    var bit_rate:Int?
    var gear_name:String?
    var quality_type:Int?
}

class Download_addr: BaseModel {
    var url_list = [String]()
    var uri:String?
}
