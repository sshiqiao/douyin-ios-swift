//
//  DeleteGroupChatRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class DeleteGroupChatRequest: BaseRequest {
    
    var id:String?
    var udid:String?
    
    static func deleteGroupChat(id:String, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = DeleteGroupChatRequest.init()
        request.id = id
        request.udid = UDID
        NetworkManager.deleteRequest(urlPath: DELETE_GROUP_CHAT_BY_ID_URL, request: request, success: { data in
            let response = BaseResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
