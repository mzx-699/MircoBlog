//
//  UserAccount.swift
//  MircoBlog
//
//  Created by apple on 2021/4/8.
//

import UIKit
///用户账号模型
/**
 {
     "access_token" = "2.00vTo1xCg1d3UD03b295f1e4YYU4GC";
     "expires_in" = 157679999;
     isRealName = true;
     "remind_in" = 157679999;
     uid = 2709030103;
 }
 */
class UserAccount: NSObject {
    ///用户授权的唯一票据，用于调用微博的开放接口，同时也是第三方应用验证微博用户登录的唯一票据
    @objc var access_token: String?
    
    //一旦从服务器获得过期时间，立刻计算准确的日期
    //重写set方法
    ///access_token的生命周期，单位是秒数
    @objc var expires_in: TimeInterval = 0 {
        didSet {
            //计算过期日期
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    ///过期日期
    @objc var expiresDate: Date?
    ///授权用户的UID，本字段只是为了方便开发者，减少一次user/show接口调用而返回的，第三方应用不能用此字段作为用户登录状态的识别，只有access_token才是用户授权的唯一票据。
    @objc var uid: String?
    ///用户昵称
    @objc var screen_name: String?
    ///用户头像地址（大图），180×180像素
    @objc var avatar_large: String?
    
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    override var description: String {
        let keys = ["access_token", "expires_in", "expiresDate", "uid", "screen_name", "avatar_large"]
        return dictionaryWithValues(forKeys: keys).description
    }
    
}
