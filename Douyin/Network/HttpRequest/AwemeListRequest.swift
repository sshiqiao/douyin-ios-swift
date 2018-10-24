//
//  AwemeListRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class AwemeListRequest: BaseRequest {
    
    var uid:String?
    var page:Int?
    var size:Int?
    
    static func findPostAwemesPaged(uid:String, page:Int, _ size:Int = 20, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = AwemeListRequest.init()
        request.uid = uid
        request.page = page
        request.size = size
        NetworkManager.getRequest(urlPath: FIND_AWEME_POST_BY_PAGE_URL, request: request, success: { data in
            if let response = AwemeListResponse.deserialize(from: data as? [String:Any]) {
                success(response)
            }
        }, failure: { error in
            failure(error)
        })
    }
    
    static func findFavoriteAwemesPaged(uid:String, page:Int, _ size:Int = 20, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = AwemeListRequest.init()
        request.uid = uid
        request.page = page
        request.size = size
        NetworkManager.getRequest(urlPath: FIND_AWEME_FAVORITE_BY_PAGE_URL, request: request, success: { data in
            if let response = AwemeListResponse.deserialize(from: data as? [String:Any]) {
                success(response)
            }
        }) { error in
            failure(error)
        }
    }
    
}
