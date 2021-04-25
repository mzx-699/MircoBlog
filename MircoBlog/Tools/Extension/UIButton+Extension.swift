//
//  UIButton+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

extension UIButton {
    //便利构造函数
    ///UIButton
    //如果图像名称使用"" 会报错误 Invalid asset name supplied: ''
    convenience init(imageName: String, backImageName: String?) {
        self.init()
        
        setImage(UIImage(named: imageName), for: .normal)
        setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        //第一个backImageName 是新变量 作用域只在if let里
        if let backImageName = backImageName {
            setBackgroundImage(UIImage(named: backImageName), for: .normal)
            setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
        }
        sizeToFit()
    }
    ///UIButton
    convenience init(title: String, color: UIColor, backImageName: String) {
        self.init()
        
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        setBackgroundImage(UIImage(named: backImageName), for: .normal)
        setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
        sizeToFit()
    }
    
    ///UIButton
    
    /// 遍历构造函数
    /// - Parameters:
    ///   - title: title
    ///   - fontSize: 字体大小
    ///   - color: color
    ///   - imageName: 图像名称
    ///   - backColor: 背景颜色 默认为nil
    convenience init(title: String, fontSize: CGFloat, color: UIColor, imageName: String?, backColor: UIColor? = nil) {
        self.init()
        
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        if let imageName = imageName {
            setImage(UIImage(named: imageName), for: .normal)
        }
        //设置背景颜色
        backgroundColor = backColor
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        sizeToFit()
    }
}
