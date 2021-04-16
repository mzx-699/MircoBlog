//
//  Status.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import UIKit

///微博数据模型
class Status: NSObject {
    
    ///    微博ID
    @objc var id: Int = 0
    ///    微博信息内容
    @objc var text: String?
    ///    微博创建时间
    @objc var created_at: String?
    ///    微博来源
    @objc var source: String?
    ///用户模型
    @objc var user: User?
    ///缩略图配图数组 key thumbnail_pic
    @objc var pic_urls: [[String : String]]?
    
    init(dict: [String : Any]) {
        super.init()
        //如果使用kvc时，value是一个字典，会直接给属性转换成字典
        setValuesForKeys(dict)
    }
    //模型套模型，另外处理
    override func setValue(_ value: Any?, forKey key: String) {
        //处理user
        if key == "user" {
            if let dict = value as? [String : Any] {
                user = User(dict: dict)
            }
            return
        }
        super.setValue(value, forKey: key)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
    override var description: String {
        let keys = ["id", "text", "created_at", "source", "user", "pic_urls"]
        return dictionaryWithValues(forKeys: keys).description
    }
}
