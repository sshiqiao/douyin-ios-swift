//
//  PostGroupChatImageRequest.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/2.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
class PostGroupChatImageRequest: BaseRequest {
    
    var udid:String?
    
    static func postGroupChatImage(data:Data, _ progress:@escaping UploadProgress, success:@escaping HttpSuccess, failure:@escaping HttpFailure) {
        let request = PostGroupChatImageRequest.init()
        request.udid = UDID
        NetworkManager.uploadRequest(urlPath: POST_GROUP_CHAT_IMAGE_URL, data: data, request: request, progress: { percent in
            progress(percent)
        }, success: { data in
            let response = GroupChatResponse.deserialize(from: data as? [String:Any])
            success(response!)
        }, failure: { error in
            failure(error)
        })
    }
    
}
