//
//  UILabel+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/7.
//

import UIKit

extension UILabel {
    
    ///UILabel
    /// -parameter color: 默认深灰色
    /// -parameter fontSize: 默认14号
    //参数后面的值，是参数的默认值，如果不传递，就是默认值
    convenience init(title: String, fontSize: CGFloat = 14, color: UIColor = UIColor.darkGray) {
        self.init()
        
        text = title
        textColor = color
        font = UIFont.systemFont(ofSize: fontSize)
        numberOfLines = 0
        textAlignment = .center

    }
}
