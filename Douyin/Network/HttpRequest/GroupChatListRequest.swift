//
//  GroupChatListRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/2.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class GroupChatListRequest: BaseRequest {
    
    var page:Int?
    var size:Int?
    
    static func findGroupChatsPaged(page:Int, _ size:Int = 20, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = GroupChatListRequest.init()
        request.page = page
        request.size = size
        NetworkManager.getRequest(urlPath: FIND_GROUP_CHAT_BY_PAGE_URL, request: request, success: { data in
            let response = GroupChatListResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
