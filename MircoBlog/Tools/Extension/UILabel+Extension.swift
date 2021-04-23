//
//  UILabel+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/7.
//

import UIKit

extension UILabel {
    
    //参数后面的值，是参数的默认值，如果不传递，就是默认值
    /// UILabel
    /// - Parameters:
    ///   - title: 文字
    ///   - fontSize: 默认14号
    ///   - color: 默认深灰色
    ///   - screenInset: 相对于屏幕左右的缩紧，默认为0，居中显示，如果设置则左对齐
    convenience init(title: String,
                     fontSize: CGFloat = 14,
                     color: UIColor = UIColor.darkGray,
                     screenInset: CGFloat = 0) {
        self.init()
        
        text = title
        textColor = color
        font = UIFont.systemFont(ofSize: fontSize)
        numberOfLines = 0
        if screenInset == 0 {
            textAlignment = .center
        }
        else {
            //设置换行高度
            //label自动换行
            preferredMaxLayoutWidth = UIScreen.main.bounds.width - 2 * screenInset
            textAlignment = .left
        }
        sizeToFit()
        

    }
}
