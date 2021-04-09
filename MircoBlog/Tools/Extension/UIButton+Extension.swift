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
    convenience init(title: String, color: UIColor, imageName: String) {
        self.init()
        
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        setBackgroundImage(UIImage(named: imageName), for: .normal)
        setBackgroundImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        sizeToFit()
    }
    
}
