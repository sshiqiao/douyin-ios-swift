//
//  CommentListRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/2.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class CommentListRequest: BaseRequest {
    
    var page:Int?
    var size:Int?
    var aweme_id:String?
    
    static func findCommentsPaged(aweme_id:String, page:Int, _ size:Int = 20, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = CommentListRequest.init()
        request.page = page
        request.size = size
        request.aweme_id = aweme_id
        NetworkManager.getRequest(urlPath: FIND_COMMENT_BY_PAGE_URL, request: request, success: { data in
            let response = CommentListResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
