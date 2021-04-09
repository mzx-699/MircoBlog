//
//  UserAccountViewModel.swift
//  MircoBlog
//
//  Created by apple on 2021/4/8.
//

import Foundation
///用户账号视图模型 -没有父类
/**
    模型通常继承自 NSObject 可以使用kvc设置属性，简化对象构造
    如果没有父类，所有的内容，都需要从头创建，量级更轻
    作用：封装‘业务逻辑’，通常没有父类
 */
class UserAccountViewModel {
    ///定义单例 - 避免重复从沙盒加载归档文件，提高效率，让access_token被访问到
    static let sharedUserAccount = UserAccountViewModel()
    
    ///用户模型
    var account: UserAccount?
    
    //外部调用方不需要关心token的值
    ///返回有效的token
    var accessToken: String? {
        //如果没有过期，返回account中的token
        if !isExpired {
            return account?.access_token
        }
        //如果过期返回nil
        return nil
    }
    
    ///用户登录标记
    var userLogon: Bool {
        //1.如果token有值，说明登录成功
        //2.如果没有过期，说明登录有效
        return account?.access_token != nil && !isExpired
    }
    ///计算型属性，类似于有返回值的函数 - 归档保存的路径
    //OC中可以定义只读属性/函数的方式实现
    private var accountPath: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        return path.appending("/account.plist")
    }
    ///判断账号是否过期
    private var isExpired: Bool {
        //判断用户账户过期日期与当前系统日期进行比较
        //改写日期，测试逻辑是否正确
        //创建日期的时候给负数，比当前时间早
//        account?.expiresDate = Date(timeIntervalSinceNow: -3600)
        //降序 用户的日期比当前日期大
        //如果account为nil，不过调用后面的属性，后面的比较也不会继续
        if account?.expiresDate?.compare(Date()) == ComparisonResult.orderedDescending {
            return false
        }
        return true
    }
    ///构造函数-私有化，要求外部只能通过单例常亮访问，不能实例化
    private init() {
        //从沙盒解档，恢复当前数据
        if !(FileManager.default.fileExists(atPath: accountPath)) {
            FileManager.default.createFile(atPath: accountPath, contents: nil, attributes: nil)
        }
        //磁盘读写速度慢
        account = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: URL(fileURLWithPath: accountPath))) as? UserAccount
        //判断token是否过期
        if isExpired {
            print("已经过期")
            //清空解档数据
            account = nil
        }
//        print(accountPath)
//        print("读取")
//        print(account ?? "")
        
    }
}

//MARK: - 用户相关的网络方法
/**
 代码重构
 1.新方法
 2.粘贴代码
 3.调整参数和返回值
 4.移动其他方法
 */

extension UserAccountViewModel {
    
    /// 加载token
    /// - Parameters:
    ///   - code: 授权码
    ///   - finished: 完成回调 是否成功
    /// - Returns:
    func loadAccessToken(code: String, finished: @escaping (_ isSuccessed: Bool)->()) {
        //4.加载accessToken
        NetworkTools.sharedTools.loadAccessToken(code: code) { (result, error) in
            if error != nil {
                print("出错了 \(error!)")
                finished(false)
                return
            }
            /**
             {
                 "access_token" = "2.00vTo1xCg1d3UD03b295f1e4YYU4GC";
                 "expires_in" = 157679999;
                 isRealName = true;
                 "remind_in" = 157679999;
                 uid = 2709030103;
             }
             */
            //swift中任何anyobjct在使用前，必要转换类型 -> as ?/! 类型
//            print(result!)
            //创建账户对象-保存在self.account中
            self.account = UserAccount(dict: result as! Dictionary<String, Any>)
//            print(account)
            self.loadUserInfo(account: self.account!, finished: finished)
            
        }
    }
    
    /// 加载用户信息
    /// - Parameter account: 用户账户对象
    private func loadUserInfo(account: UserAccount, finished: @escaping (_ isSuccessed: Bool)->()) {
        NetworkTools.sharedTools.loadUserInfo(uid: account.uid!) { (result, error) in
            if error != nil {
                print("出错了 \(error!)")
                finished(false)
                return
            }
            //如果使用if/guard as 统统使用?
            //以下做了两个判断
            //1.result 一定有内容
            //2.一定是字典
            guard let dict = result as? [String : Any] else {
                print("格式错误")
                finished(false)
                return
            }
            //保存用户信息
            account.screen_name = dict["screen_name"] as? String
            account.avatar_large = dict["avatar_large"] as? String
            
            //保存对象
            //自动调用对象的encode方法
            let data = try! NSKeyedArchiver.archivedData(withRootObject: account, requiringSecureCoding: true)
            try! data.write(to: URL(fileURLWithPath: self.accountPath))
//            print(self.accountPath)
            //需要完成回调
            finished(true)
        }
    }
}
