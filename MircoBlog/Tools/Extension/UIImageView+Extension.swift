//
//  UIImageView+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/7.
//

import UIKit

extension UIImageView {
    
    convenience init(imageName: String) {
        self.init(image: UIImage(named: imageName))
        
    }
}
