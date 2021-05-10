//
//  String+Regex.swift
//  处理来源
//
//  Created by apple on 2021/5/10.
//

import Foundation

extension String {
    
    ///当前文字中过滤链接和文字
    //元组 一个函数返回多个数值
    func href() -> (link: String, source: String)? {
        //1.创建正则表达式
        //匹配方案 用来过滤字符串
        let pattern = "<a href=\"(.*?)\" .*?\">(.*?)</a>"
        //throws 针对pattern是否正确的异常处理
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        //firstMatch 在指定字符串中，查找第一个和pattern符合的字符串
        guard let result = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) else {
            print("没有匹配内容")
            return nil
        }
        let str = self as NSString
        
        let r1 = result.range(at: 1)
        let link = str.substring(with: r1)
        let r2 = result.range(at: 2)
        let source = str.substring(with: r2)
        
        return (link, source)
    }
}
