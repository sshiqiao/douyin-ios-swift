//
//  PostGroupChatTextRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class PostGroupChatTextRequest: BaseRequest {
    
    var udid:String?
    var text:String?
    
    static func postGroupChatText(text:String, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = PostGroupChatTextRequest.init()
        request.udid = UDID
        request.text = text
        NetworkManager.postRequest(urlPath: POST_GROUP_CHAT_TEXT_URL, request: request, success: { data in
            let response = GroupChatResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
