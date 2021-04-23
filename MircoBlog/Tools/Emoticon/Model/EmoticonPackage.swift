//
//  EmoticonPackage.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//

import UIKit
//MARK: - 表情包模型
class EmoticonPackage: NSObject {
    ///表情包所占路径
    @objc var id: String?
    ///表情包的名称显示在toolbar中
    @objc var group_name_cn: String?
    ///表情数组，保证在使用的时候，数组已经存在，可以直接追加数据
    @objc lazy var emoticons = [Emoticon]()
    
    init(dict: [String : Any]) {
        super.init()
        //setvalueforkey 不会按照期望的顺序加载数据
        //不能保证emoticons的路径被成功拼接
        id = dict["id"] as? String
        group_name_cn = dict["group_name_cn"] as? String
        //获得字典数组
        if let array = dict["emoticons"] as? [[String : Any]] {
            //遍历数组
            var index = 0
            for var d in array {
                //是否有png
                if let png = d["png"] as? String, let dir = id {
                    //重新设置字典的png的value
                    d["png"] = dir + "/" + png
                }
                emoticons.append(Emoticon(dict: d))
                //每隔20个加添加删除按钮
                index += 1
                if index == 20 {
                    emoticons.append(Emoticon(isRemoved: true))
                    index = 0
                }
            }
        }
        //添加空白按钮
        appendEmptyEmoticon()
    }
    ///在表情数组末尾，添加空白表情
    private func appendEmptyEmoticon() {
        //取表情的余数
        let count = emoticons.count % 21
        //只有最近和默认需要添加空白表情
        if emoticons.count > 0 && count == 0 {
            return
        }
        
        print(count)
        //添加空白表情
        for _ in count ..< 20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        //末尾添加一个删除按钮
        emoticons.append(Emoticon(isRemoved: true))
    }

    override var description: String {
        let keys = ["id", "group_name_cn", "emoticons"]
        
        return dictionaryWithValues(forKeys: keys).description
    }
}
