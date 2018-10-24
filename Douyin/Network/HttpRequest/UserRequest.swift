//
//  UserRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class UserRequest: BaseRequest {
    
    var uid:String?
    
    static func findUser(uid:String, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = UserRequest.init()
        request.uid = uid
        NetworkManager.getRequest(urlPath: FIND_USER_BY_UID_URL, request: request, success: { data in
            let response = UserResponse.deserialize(from: data as? [String:Any])
            success(response?.data ?? User.init())
        }, failure: { error in
            failure(error)
        })
    }
    
}
