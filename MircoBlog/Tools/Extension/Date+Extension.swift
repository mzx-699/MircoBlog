//
//  Date+Extension.swift
//  时间转换
//
//  Created by apple on 2021/5/10.
//

import Foundation

extension Date {
    
    /// 将新浪微博格式的字符串转换成日期
    /// - Parameter string: 返回的日期字符串
    /// - Returns: 格式化后的日期
    static func sinaDate(string: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        //星期 月 日 时 分 秒 时区 年
        df.dateFormat = "EEE MM dd HH:mm:ss zzz yyyy"
        return df.date(from: string)
    }
    /**
     日期描述信息
     刚刚(一分钟内)
     X分钟前(一小时内)
     X小时前(当天)
     昨天 HH:mm(昨天)
     MM-dd HH:mm(一年内)
     yyyy-MM-dd HH:mm(更早期)
     */
    var dateDescription: String {
        
        //取出当前日历 - 提供了大量日历相关的操作函数
        let calendar = Calendar.current
        //处理今天的日期
        if calendar.isDateInToday(self) {
            //返回距离这个时间的秒数
            let delta = Int(Date().timeIntervalSince(self))
            if delta < 60 {
                return "刚刚"
            }
            if delta < 60 * 60 {
                return "\(delta / 60) 分钟前"
            }
            
            return "\(delta / 60 / 60) 小时前"
        }
        var fmt = "HH:mm"
        if calendar.isDateInYesterday(self) {
            fmt = "昨天 " + fmt
        } else {
            fmt = "MM-dd " + fmt
            //取出年数
            //calendar.component(.year, from: self)
            //比较两个日期之前是否有一个完整的年度差值
            let comps = calendar.dateComponents([.year], from: self, to: Date())
            if comps.year! > 0 {
                fmt = "yyyy-" + fmt
            }
        }
        //根据格式字符串生成描述字符串
        let df = DateFormatter()
        df.dateFormat = fmt
        df.locale = Locale(identifier: fmt)
        return df.string(from: self)
    }
}
