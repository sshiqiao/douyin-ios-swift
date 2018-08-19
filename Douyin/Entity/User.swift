//
//  User.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class User: BaseModel {
    
    var weibo_name:String?
    var google_account:String?
    var special_lock:Int?
    var is_binded_weibo:Bool?
    var shield_follow_notice:Int?
    var user_canceled:Bool?
    var avatar_larger:Avatar?
    var accept_private_policy:Bool?
    var follow_status:Int?
    var with_commerce_entry:Bool?
    var original_music_qrcode:String?
    var authority_status:Int?
    var youtube_channel_title:String?
    var is_ad_fake:Bool?
    var prevent_download:Bool?
    var verification_type:Int?
    var is_gov_media_vip:Bool?
    var weibo_url:String?
    var twitter_id:String?
    var need_recommend:Int?
    var comment_setting:Int?
    var status:Int?
    var unique_id:String?
    var hide_location:Bool?
    var enterprise_verify_reason:String?
    var aweme_count:Int?
    var story_count:Int?
    var unique_id_modify_time:Int?
    var follower_count:Int?
    var apple_account:Int?
    var short_id:String?
    var account_region:String?
    var signature:String?
    var twitter_name:String?
    var avatar_medium:Avatar?
    var verify_info:String?
    var create_time:Int?
    var story_open:Bool?
    var policy_version:Policy_version?
    var region:String?
    var hide_search:Bool?
    var avatar_thumb:Avatar?
    var school_poi_id:String?
    var shield_comment_notice:Int?
    var total_favorited:Int?
    var video_icon:Video_icon?
    var original_music_cover:String?
    var following_count:Int?
    var shield_digg_notice:Int?
    var  geofencing:[Geofencing]?
    var bind_phone:String?
    var has_email:Bool?
    var live_verify:Int?
    var birthday:String?
    var duet_setting:Int?
    var ins_id:String?
    var follower_status:Int?
    var live_agreement:Int?
    var neiguang_shield:Int?
    var uid:String?
    var secret:Int?
    var is_phone_binded:Bool?
    var live_agreement_time:Int?
    var weibo_schema:String?
    var is_verified:Bool?
    var custom_verify:String?
    var commerce_user_level:Int?
    var gender:Int?
    var has_orders:Bool?
    var youtube_channel_id:String?
    var reflow_page_gid:Int?
    var reflow_page_uid:Int?
    var nickname:String?
    var school_type:Int?
    var avatar_uri:String?
    var weibo_verify:String?
    var favoriting_count:Int?
    var share_qrcode_uri:String?
    var room_id:Int?
    var constellation:Int?
    var school_name:String?
    var activity:Activity?
    var user_rate:Int?
    var video_icon_virtual_URI:String?
}

class Avatar: BaseModel {
    var url_list = [String]()
    var uri:String?
}

class Policy_version: BaseModel {
    
}

class Geofencing: BaseModel {
    
}

class Video_icon: BaseModel {
    var url_list = [String]()
    var uri:String?
}

class Activity: BaseModel {
    var digg_count:String?
    var use_music_count:String?
}
