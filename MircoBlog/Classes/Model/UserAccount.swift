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
class UserAccount: NSObject, NSCoding, NSSecureCoding {
    //MARK: - 属性
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
    
    //MARK: - 初始化 KVC
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
    //MARK: - 保存当前对象
    func saveUserAccount() {
        //1.保存路径
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        //单纯的as在swift中只有三个地方要用
        path = path.appending("/account.plist")
        let data = try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
        //实际开发中，一定要去确认文件保存了
//        print(path)
//        print(self)
        //只能存在data文件中
        try! data.write(to: URL(fileURLWithPath: path))
    }
    
    //MARK: - ‘键值’归档和解档
    
    /// 归档 - 把当前对象保存到磁盘前，将对象编码成二进制数据，跟网络序列化很像
    /// - Parameter coder: 编码器
    func encode(with coder: NSCoder) {
        coder.encode(access_token, forKey: "access_token")
        coder.encode(expiresDate, forKey: "expiresDate")
        coder.encode(uid, forKey: "uid")
        coder.encode(screen_name, forKey: "screen_name")
        coder.encode(avatar_large, forKey: "avatar_large")
    }
    
    //required 仅在解当的方法用，没有继承性，所有的对象只能解档出当前的类对象
    /// 解档 -从磁盘加载二进制文件，转换成对象时调用，跟网络反序列化很像
    /// - Parameter coder: 解码器
    required init?(coder: NSCoder) {
        access_token = coder.decodeObject(forKey: "access_token") as? String
        expiresDate = coder.decodeObject(forKey: "expiresDate") as? Date
        uid = coder.decodeObject(forKey: "uid") as? String
        screen_name = coder.decodeObject(forKey: "screen_name") as? String
        avatar_large = coder.decodeObject(forKey: "avatar_large") as? String
    }
    static var supportsSecureCoding: Bool = true
}

//在extension中 只允许写便利构造函数，而不能写指定构造函数
//不能定义存储型属性，定义存储型属性，会破坏类本身的结构
