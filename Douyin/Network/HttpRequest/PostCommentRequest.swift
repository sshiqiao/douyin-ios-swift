//
//  PostCommentRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class PostCommentRequest: BaseRequest {
    
    var aweme_id:String?
    var text:String?
    var udid:String?
    
    
    static func postCommentText(aweme_id:String, text:String, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = PostCommentRequest.init()
        request.aweme_id = aweme_id
        request.text = text
        request.udid = UDID
        NetworkManager.postRequest(urlPath: POST_COMMENT_URL, request: request, success: { data in
            let response = CommentResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
