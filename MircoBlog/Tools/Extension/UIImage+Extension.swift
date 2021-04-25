//
//  UIImage+Extension.swift
//  微博-照片选择
//
//  Created by apple on 2021/4/25.
//

import UIKit

extension UIImage {
    
    
    /// 将图像缩放到指定的宽度
    /// - Parameter width: 目标宽度
    /// - Returns: 如果给定的图片宽度小于指定宽度，直接返回
    func scaleToWith(width: CGFloat) -> UIImage {
        //1.判断宽度
        if width > size.width {
            return self
        }
        //2.计算比例
        let height = size.height / size.width * width
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        //3.使用核心绘图，绘制新的图像
        //3.1上下文
        UIGraphicsBeginImageContext(rect.size)
        //3.2绘图 在指定区域拉伸绘制
        self.draw(in: rect)
        //3.3取结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        //3.4关闭上下文
        UIGraphicsEndImageContext()
        //3.5返回结果
        return result!
    }
}
