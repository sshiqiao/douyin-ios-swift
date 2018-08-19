//
//  GroupChat.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/2.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class GroupChat: BaseModel {
    var id:String?
    var msg_type:String?
    var msg_content:String?
    var visitor:Visitor?
    var pic_original:PictureInfo?
    var pic_large:PictureInfo?
    var pic_medium:PictureInfo?
    var pic_thumbnail:PictureInfo?
    var create_time:Int?
    
    var taskId:Int?
    var isTemp:Bool = false
    var isFailed:Bool = false
    var isCompleted:Bool = false
    var percent:Float?
    var picImage:UIImage?
    var cellHeight:CGFloat = 0
    
    func createTimeChat() -> GroupChat {
        let timeChat = GroupChat.init()
        timeChat.msg_type = "time"
        timeChat.msg_content = Date.formatTime(timeInterval: TimeInterval(self.create_time ?? 0))
        timeChat.create_time = self.create_time
        timeChat.cellHeight = TimeCell.cellHeight(chat: timeChat)
        return timeChat
    }
    
    static func initImageChat(image:UIImage) -> GroupChat {
        let chat = GroupChat.init()
        chat.msg_type = "image"
        chat.isTemp = true
        chat.picImage = image
        let picInfo = PictureInfo.init()
        picInfo.width = image.size.width
        picInfo.height = image.size.height
        chat.pic_original = picInfo
        chat.pic_large = picInfo
        chat.pic_medium = picInfo
        chat.pic_thumbnail = picInfo
        return chat
    }
    
    
    static func initTextChat(text:String) -> GroupChat {
        let chat = GroupChat.init()
        chat.msg_type = "text"
        chat.isTemp = true
        chat.msg_content = text
        return chat
    }
    
    func updateTempImageChat(chat:GroupChat) {
        id = chat.id
        pic_original = chat.pic_original
        pic_large = chat.pic_large
        pic_medium = chat.pic_medium
        pic_thumbnail = chat.pic_thumbnail
        create_time = chat.create_time
        isTemp = true
        percent = 1.0
        isCompleted = true
        isFailed = false
    }
    
    func updateTempTextChat(chat:GroupChat) {
        id = chat.id
        create_time = chat.create_time
        isTemp = true
        isCompleted = true
        isFailed = false
    }
}
