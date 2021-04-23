//
//  UITextView+Emoticon.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/22.
//

import UIKit
/**
 代码复核 对重构的代码进行检查
 1.修改注释
 2.确认是否需要进一步重构
 3.再一次检查返回值和参数
 */
extension UITextView {
    
    /// 图片表情完整字符串内容 -- 计算型属性
    /// - Returns: 返回最终字符串
    var emoitconText: String {
        //输出整个文本
        let attrText = attributedText
        var strM = String()
        attrText?.enumerateAttributes(in: NSRange(location: 0, length: attrText!.length), options: [], using: { (dict, range, _) in
//            print("-----")
            
            //如果字典中包含NSAttachment 是图片
            //否则是字符串，可以通过range获得
            if let attachment = dict[NSAttributedString.Key(rawValue: "NSAttachment")] as? EmoticonAttachment {
                //通过attachment获取字符串
                strM += attachment.emoticon.chs ?? ""
            }
            else {
                let str = (attrText!.string as NSString).substring(with: range)
                strM += str
            }
        })
        return strM
    }
    
    func insertEmotion(em: Emoticon) {
        //1.空白表情
        if em.isEmpty {
            return
        }
        //2.删除按钮
        if em.isRemoved {
            deleteBackward()
            return
        }
        //3.emoji
        if let emoji = em.emoji {
            replace(selectedTextRange!, withText: emoji)
            return
        }
        //4.图文表情
        insertImageEmoticon(em: em)
        //5.通知代理文本变化了 --问号表示，如果代理没有实现方法则什么都不做
        //调用代理方法
        delegate?.textViewDidChange?(self)
    }
    private func insertImageEmoticon(em: Emoticon) {

        //1.图片属性文本
        let imageText = EmoticonAttachment(emoticon: em).imageText(font: font!)
        //2.记录textview attributestring 转换成可变文本
        let strM = NSMutableAttributedString(attributedString: attributedText)
        //3.插入图片文本
        strM.replaceCharacters(in: selectedRange, with: imageText)
        //4.替换属性文本
        //4.1记录光标位置
        let range = selectedRange
        //4.2替换文本
        attributedText = strM
        //4.3恢复光标
        selectedRange = NSRange(location: range.location + 1, length: 0)
    }
}
