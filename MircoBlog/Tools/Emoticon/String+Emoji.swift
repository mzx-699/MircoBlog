//
//  String+Emoji.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//

import Foundation

extension String {
    
    //返回当前字符串中的16进制的emoji字符串
    var emoji: String {
        //文本扫描器-扫描指定格式的字符串
        let scanner = Scanner(string: self)
        //unicode的值
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        //转换成unicode字符
        let chr = Character(Unicode.Scalar(UInt32(value))!)
        //转换成字符串
        return "\(chr)"
    }
}
