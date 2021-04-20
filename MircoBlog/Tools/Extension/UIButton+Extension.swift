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
    convenience init(imageName: String, backImageName: String) {
        self.init()
        
        setImage(UIImage(named: imageName), for: .normal)
        setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        setBackgroundImage(UIImage(named: backImageName), for: .normal)
        setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
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
    convenience init(title: String, fontSize: CGFloat, color: UIColor, imageName: String) {
        self.init()
        
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        setImage(UIImage(named: imageName), for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        sizeToFit()
    }
}
