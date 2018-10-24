//
//  DeleteCommentRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class DeleteCommentRequest: BaseRequest {
    
    var cid:String?
    var udid:String?
    
    static func deleteComment(cid:String, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = DeleteCommentRequest.init()
        request.cid = cid
        request.udid = UDID
        NetworkManager.deleteRequest(urlPath: DELETE_COMMENT_BY_ID_URL, request: request, success: { data in
            let response = BaseResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
