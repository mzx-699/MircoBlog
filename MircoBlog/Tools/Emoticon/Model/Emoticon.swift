//
//  Emoticon.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//

import UIKit
//MARK: - 表情模型
class Emoticon: NSObject {
    ///发送给服务器的表情字符串
    @objc var chs: String?
    ///在本地显示的图片名称 + 表情路径
    @objc var png: String?
    ///emoji的字符串编码
    @objc var code: String? {
        didSet {
            emoji = code?.emoji
        }
    }
    ///emoji字符串
    var emoji: String?
    ///表情使用次数
    @objc var times = 0
    ///完整路径
    var imagePath: String {
        //判断是否有图片
        if png == nil {
            return ""
        }
        //拼接完整路径
        return Bundle.main.bundlePath + "/Emoticons.bundle/" + png!
    }
    ///是否删除按钮标记
    @objc var isRemoved = false
    ///是否是空白按钮标记
    var isEmpty = false
    //MARK: - 构造函数
    init(isEmpty: Bool) {
        self.isEmpty = isEmpty
        super.init()
    }
    init(isRemoved: Bool) {
        self.isRemoved = isRemoved
        super.init()
    }
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    override var description: String {
        let keys = ["chs", "png", "code", "isRemoved", "times"]
        
        return dictionaryWithValues(forKeys: keys).description
    }
}
