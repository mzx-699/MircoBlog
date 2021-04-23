//
//  UIBarButtonItem+Extension.swift
//  MircoBlog
//
//  Created by apple on 2021/4/22.
//

import UIKit

extension UIBarButtonItem {
    
    /// 便利构造函数
    /// - Parameters:
    ///   - imageName: 图片名
    ///   - tartget: 监听对象
    ///   - actionName: 监听方法
    convenience init(imageName: String, tartget: Any?, actionName: String?) {
        let button = UIButton(imageName: imageName, backImageName: "")
        //判断actionName
        if let actionName = actionName {
            button.addTarget(tartget, action: Selector(actionName), for: .touchUpInside)
        }
        self.init(customView: button)
    
    }
}
