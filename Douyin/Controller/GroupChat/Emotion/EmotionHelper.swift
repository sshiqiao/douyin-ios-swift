//
//  EmotionHelper.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class EmotionHelper:NSObject {
    
    static let EmotionFont = BigFont
    
    //获取emotion.json中的以表情图片文件名作为key值、表情对应的文本作为value值的字典dic
    static let emotionDic:[String:String] = {
        return String.readJson2DicWithFileName(fileName: "emotion")["dict"]
        }() as! [String : String]
    
    //获取emotion.json中包含了表情选择器中每一页的表情图片文件名的二维数组array
    static let emotionArray:[[String]] = {
        return String.readJson2DicWithFileName(fileName: "emotion")["array"]
        }() as! [[String]]
    
    //通过正则表达式匹配文本，表情文本转换为NSTextAttachment图片文本，例：[飞吻]→😘
    static func stringToEmotion(str:NSAttributedString) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init(attributedString: str)
        let pattern = "\\[.*?\\]"
        var regex:NSRegularExpression?
        do {
            regex = try NSRegularExpression.init(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
        } catch {
            print("stringToEmotion error:" + error.localizedDescription)
        }
        let matches:[NSTextCheckingResult] = regex?.matches(in: str.string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: str.length)) ?? [NSTextCheckingResult]()
        var lengthOffset = 0
        for match in matches {
            let range = match.range
            let emotionValue = str.string.substring(range: range)
            let emotinoKey = EmotionHelper.emotionKeyFromValue(value: emotionValue)
            let attachment:NSTextAttachment = NSTextAttachment()
            let emotionPath = EmotionHelper.emotionIconPath(emotionKey: emotinoKey)
            
            attachment.image = UIImage.init(contentsOfFile: emotionPath)
            attachment.bounds = CGRect.init(x: 0, y: EmotionFont.descender, width: EmotionFont.lineHeight, height: EmotionFont.lineHeight/((attachment.image?.size.width)!/(attachment.image?.size.height)!))
            let matchStr = NSAttributedString.init(attachment: attachment)
            let emotionStr = NSMutableAttributedString.init(attributedString: matchStr)
            emotionStr.addAttribute(NSAttributedString.Key.font, value: EmotionFont, range: NSRange.init(location: 0, length: 1))
            attributedString.replaceCharacters(in: NSRange.init(location: range.location - lengthOffset, length: range.length), with: emotionStr)
            lengthOffset += (range.length - 1)
        }
        return attributedString
    }
    
    //NSTextAttachment图片文本转换为表情文本，例：😘→[飞吻]
    static func emotionToString(str:NSMutableAttributedString) -> NSAttributedString {
        str.enumerateAttribute(.attachment, in: NSRange.init(location: 0, length: str.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                if let emotionKey = attachment.emotionKey {
                    let emotionValue = EmotionHelper.emotionValueFromKey(key: emotionKey)
                    str.replaceCharacters(in: range, with: emotionValue)
                }
            }
        }
        return str
    }

    //通过表情文本value值获取表情图片文件名key值
    static func emotionKeyFromValue(value:String) -> String {
        let emotionDic:[String:String] = EmotionHelper.emotionDic
        for key in emotionDic.keys {
            if emotionDic[key] == value {
                return key
            }
        }
        return ""
    }

    //通过表情图片文件名key值获取表情文本value值
    static func emotionValueFromKey(key:String) -> String {
        let emotionDic:[String:String] = EmotionHelper.emotionDic
        return emotionDic[key] ?? ""
    }
    
    static func insertEmotion(str:NSAttributedString, index:Int, key:String) -> NSAttributedString {
        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.emotionKey = key
        let emotionPath = EmotionHelper.emotionIconPath(emotionKey:key)
        attachment.image = UIImage.init(contentsOfFile: emotionPath)
        attachment.bounds = CGRect.init(x: 0, y: EmotionFont.descender, width: EmotionFont.lineHeight, height: EmotionFont.lineHeight/((attachment.image?.size.width)!/(attachment.image?.size.height)!))
        let matchStr = NSAttributedString.init(attachment: attachment)
        let emotionStr = NSMutableAttributedString.init(attributedString: matchStr)
        emotionStr.addAttribute(NSAttributedString.Key.font, value: EmotionFont, range: NSRange.init(location: 0, length: emotionStr.length))
        let attrStr = NSMutableAttributedString.init(attributedString: str)
        
        attrStr.replaceCharacters(in: NSRange.init(location: index, length: 0), with: emotionStr)
        return attrStr
    }
    
    static func emotionIconPath(emotionKey:String) -> String {
        let emotionsPath = Bundle.main.path(forResource: "Emoticons", ofType: "bundle") ?? ""
        let emotionPath = emotionsPath + "/" + emotionKey
        return emotionPath
    }
}
