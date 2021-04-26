//
//  UIColor+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/25.
//

import UIKit

extension UIColor {
    
    class func randomColor() -> UIColor {
        //0~255
        let r = CGFloat(arc4random() % 256) / 255
        let g = CGFloat(arc4random() % 256) / 255
        let b = CGFloat(arc4random() % 256) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
