//
//  Date+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/8.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

extension Date {
    static func formatTime(timeInterval:TimeInterval) -> String {
        let date = Date.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        if date.isToday() {
            if date.isJustNow() {
                return "刚刚"
            } else {
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
        } else {
            if date.isYestoday() {
                formatter.dateFormat = "昨天HH:mm"
                return formatter.string(from: date)
            } else if date.isCurrentWeek() {
                formatter.dateFormat = date.dateToWeekday() + "HH:mm"
                return formatter.string(from: date)
            } else {
                if date.isCurrentYear() {
                    formatter.dateFormat = "MM-dd  HH:mm"
                } else {
                    formatter.dateFormat = "yy-MM-dd  HH:mm"
                }
                return formatter.string(from: date)
            }
        }
    }
    
    func isJustNow() -> Bool {
        let now = Date.init().timeIntervalSince1970
        return fabs(now - self.timeIntervalSince1970) < 60 * 2 ? true : false
    }
    
    func isCurrentWeek() -> Bool {
        let nowDate = Date.init().dateFormatYMD()
        let selfDate = self.dateFormatYMD()
        let calendar = Calendar.current
        let cmps = calendar.dateComponents([.day], from: selfDate, to: nowDate)
        return cmps.day ?? 0 <= 7
    }
    
    func isCurrentYear() -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year], from: Date.init())
        let selfComponents = calendar.dateComponents([.year], from: self)
        return selfComponents.year == nowComponents.year
    }
    
    func dateToWeekday() -> String {
        let weekdays = ["", "星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        var calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        calendar.timeZone = timeZone!
        let theComponents = calendar.dateComponents([.weekday], from: self)
        return weekdays[theComponents.weekday ?? 0]
    }
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.day, .month, .year], from: Date.init())
        let selfComponents = calendar.dateComponents([.day, .month, .year], from: self)
        return nowComponents.year == selfComponents.year && nowComponents.month == selfComponents.month && nowComponents.day == selfComponents.day
    }
    
    func isYestoday() -> Bool {
        let nowDate = Date.init().dateFormatYMD()
        let selfDate = self.dateFormatYMD()
        let calendar = Calendar.current
        let cmps = calendar.dateComponents([.day], from: selfDate, to: nowDate)
        return cmps.day == 1
    }
    
    func dateFormatYMD() -> Date {
        let fmt = DateFormatter.init()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
        return fmt.date(from: selfStr)!
    }
}
