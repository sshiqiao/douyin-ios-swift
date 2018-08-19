//
//  Aweme.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class Aweme: BaseModel {
    var author:User?
    var music:Music?
    var cmt_swt:Bool?
    var video_text = [Video_text]()
    var risk_infos:Risk_infos?
    var is_top:Int?
    var region:String?
    var user_digged:Int?
    var cha_list = [Cha_list]()
    var is_ads:Bool?
    var bodydance_score:Int?
    var law_critical_country:Bool?
    var author_user_id:Int?
    var create_time:Int?
    var statistics:Statistics?
    var video_labels = [Video_labels]()
    var sort_label:String?
    var descendants:Descendants?
    var geofencing = [Geofencing]()
    var is_relieve:Bool?
    var status:Status?
    var vr_type:Int?
    var aweme_type:Int?
    var aweme_id:String?
    var video:Video?
    var is_pgcshow:Bool?
    var desc:String?
    var is_hash_tag:Int?
    var share_info:Aweme_share_info?
    var share_url:String?
    var scenario:Int?
    var label_top:Label_top?
    var rate:Int?
    var can_play:Bool?
    var is_vr:Bool?
    var text_extra = [Text_extra]()

}

class Video_text: BaseModel {
}

class Risk_infos: BaseModel  {
    var warn:Bool?
    var content:String?
    var risk_sink:Bool?
    var type:Int?
}

class Cha_list: BaseModel  {
    var author:User?
    var user_count:Int?
    var schema:String?
    var sub_type:Int?
    var desc:String?
    var is_pgcshow:Bool?
    var cha_name:String?
    var type:Int?
    var cid:String?
}

class Statistics: BaseModel  {
    var digg_count:Int?
    var aweme_id:Int?
    var share_count:Int?
    var play_count:Int?
    var comment_count:Int?
}

class Video_labels: BaseModel  {
}

class Descendants: BaseModel  {
    var notify_msg:String?
    var platforms = [String]()
}

class Status: BaseModel  {
    var allow_share:Bool?
    var private_status:Int?
    var is_delete:Bool?
    var with_goods:Bool?
    var is_private:Bool?
    var with_fusion_goods:Bool?
    var allow_comment:Bool?
}

class Aweme_share_info: BaseModel  {
    var share_weibo_desc:String?
    var share_title:String?
    var share_url:String?
    var share_desc:String?
}

class Label_top: BaseModel  {
    var url_list = [String]()
    var uri:String?
}

class Text_extra: BaseModel  {
}

