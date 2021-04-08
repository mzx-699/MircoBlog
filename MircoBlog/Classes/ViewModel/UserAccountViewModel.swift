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
    
    ///用户模型
    var account: UserAccount?
    
    ///计算型属性，类似于有返回值的函数 - 归档保存的路径
    private var accountPath: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        return path.appending("/account.plist")
    }
    ///构造函数
    init() {
        //从沙盒解档，恢复当前数据
        if !(FileManager.default.fileExists(atPath: accountPath)) {
            FileManager.default.createFile(atPath: accountPath, contents: nil, attributes: nil)
        }
//        print(accountPath)
        account = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: URL(fileURLWithPath: accountPath))) as? UserAccount
        
        print(account ?? "")
        
    }
}
