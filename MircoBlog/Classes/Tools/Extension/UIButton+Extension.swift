//
//  UIButton+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

extension UIButton {
    //便利构造函数
    convenience init(imageName: String, backImageName: String) {
        self.init()
        
        setImage(UIImage(named: imageName), for: .normal)
        setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        setBackgroundImage(UIImage(named: backImageName), for: .normal)
        setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
        sizeToFit()
    }
}
