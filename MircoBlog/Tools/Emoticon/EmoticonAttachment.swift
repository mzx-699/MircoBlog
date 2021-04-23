//
//  EmoticonAttachment.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/22.
//

import UIKit
///表情附件
class EmoticonAttachment: NSTextAttachment {
    ///表情模型
    var emoticon: Emoticon
    
    ///将当前附件中的emoticon转换成属性文本
    func imageText(font: UIFont) -> NSAttributedString {
        image = UIImage(contentsOfFile: emoticon.imagePath)
        //线高 字体的高度
        let lineHeight = font.lineHeight
        //frame = center + bounds * transform
        //bounds(x, y) = contentoffset
        //可以设置bounds的偏移
        bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        //获得图片文本
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
        //添加字体 uikit框架中第一个头文件
        imageText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: 1))
        return imageText
    }
    //MARK: - 构造函数
    init(emoticon: Emoticon) {
        self.emoticon = emoticon
        super.init(data: nil, ofType: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
