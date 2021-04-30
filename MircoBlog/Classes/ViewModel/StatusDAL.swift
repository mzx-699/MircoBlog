//
//  StatusDAL.swift
//  MircoBlog
//
//  Created by apple on 2021/4/30.
//

import Foundation
///专门负责处理本地 SQLite和网络数据 --- 数据访问层 Data Access Layer
class StatusDAL {
    ///加载微博数据
    class func loadStatus() {
        //检查本地是否存在缓存数据
        
        //如果有 返回缓存数据
        
        //如果没有 加载网络数据
        
        //将网络返回的数据，保存在本地数据库，以便以后使用
        
        //返回网络数据
        
    }
    
    /// 检查本地数据库中是否存在需要的数据
    /// - Parameters:
    ///   - since_id: 下拉刷新
    ///   - max_id: 上拉刷新
    class func checkCacheDate(since_id: Int, max_id: Int) {
        print("检查本地数据 \(since_id) \(max_id)")
        //用户id
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            print("用户没有登陆")
            return
        }

        //准备sql
        var sql = "SELECT statusId, status, userId FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        if since_id > 0 {
            sql += "    AND statusId > \(since_id) \n"
        }
        else if max_id > 0 {
            sql += "    AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        SQLiteManager.sharedManager.queue.inDatabase { (db) in
            
        }
    }
    /// 将网络返回的数据保存至本地数据库
    /// - Parameter array: 网络返回的字典数组
    class func saveCacheDate(array: [[String : Any]]) {
        //测试
//        print(array)
        //用户id
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            print("用户没有登陆")
            return
        }
        //准备sql
        //确认参数
        /**
         微博id 通过字典获取
         微博json 字典序列化
         userid 登陆的用户
         */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, status, userId) VALUES (?, ?, ?);"
        //遍历数组 如果不能确认数据插入的消耗时间，通过测试代码进行性能测试
        SQLiteManager.sharedManager.queue.inTransaction { (db, rollback) in
            for dict in array {
                //微博id
                let statusId = dict["id"] as! Int
                //序列化字典 字典变成二进制数据
                let json = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let str = String(data: json, encoding: .utf8)!
                //插入数据
                if !db.executeUpdate(sql, withArgumentsIn: [statusId, str, userId]) {
                    print("插入数据失败")
                    //回滚
                    rollback.pointee = true
                    break
                }
            }
        }
        print("数据插入完成")
    }
}
