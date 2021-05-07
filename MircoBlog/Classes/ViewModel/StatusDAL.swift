//
//  StatusDAL.swift
//  MircoBlog
//
//  Created by apple on 2021/4/30.
//
//微博可以做商量缓存，保证用户在没网的情况下，看到少量数据
//如果两次刷新时间间隔较长，会导致数据丢失
//如果用户关注了新的用户，在有数据缓存的时间段内，新关注的用户数据看不到
//配合其他接口可以解决
//如果有一个我们关注用户发布了一条不应该发布的微博，官方会在第一时间删除
//不适合缓存的数据：
//实事敏感度高，实时性要求高，缓存难度高的（变化频率高，不可控因素多）
//适合做缓存的数据
//变换慢，没有实时性/敏感度
import Foundation
///专门负责处理本地 SQLite和网络数据 --- 数据访问层 Data Access Layer
///最大缓存时间
private let maxCacheDateTime: TimeInterval = 60 //7 * 24 * 60 * 60
class StatusDAL {
    /**
     清理数据缓存不能交给用户操作
     一定要定期清理数据库的缓存
     - sql的数据库，随着数据的增加，不断变大
     - 但是 如果删除了数据，数据库不会变小，会保持原有大小，准备下一次到这么大，sql不会额外分配磁盘空间
     - 一般不会把 图片/音频/视频 存放在数据库中，不便于检索，占用磁盘空间
     */
    ///清理‘早于过期日期’的数据
    class func clearDataCache() {
        //1.准备日期
        //找比今天早的时间
        let date = Date(timeIntervalSinceNow: -maxCacheDateTime)
        //日期格式转换
        let df = DateFormatter()
        //指定区域 在模拟器不需要，真机一定需要
        df.locale = Locale(identifier: "en")
        //指定日期格式
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //获取日期结果
        let dateStr = df.string(from: date)
        //2.执行sql
        //开发调试删除sql语句的时候，要先用select进行测试 select 不能用update测试 要用query
        let sql = "DELETE FROM T_Status WHERE createTime < ?;"
        SQLiteManager.sharedManager.queue.inDatabase { (db) in
            if db.executeUpdate(sql, withArgumentsIn: [dateStr]) {
                if db.changes > 0 {
                    print("删除了\(db.changes)条数据")
                }
                
            }
            
        }
    }
    ///加载微博数据
    class func loadStatus(since_id: Int, max_id: Int, finished: @escaping (_ array: [[String : Any]]?) -> ()) {
        //检查本地是否存在缓存数据
        let array = checkCacheDate(since_id: since_id, max_id: max_id)
        //如果有 返回缓存数据
        if array!.count > 0 {
            print("查询到缓存数据 \(array!.count)")
            finished(array)
            return
        }
        //如果没有 加载网络数据
        print("加载网络数据")
        NetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id) { (result, error) in
            if error != nil {
                print("出错了\(error!)")
                finished(nil)
                return
            }
            //判断数据结构是否正确
            guard let array = (result as! [String : Any])["statuses"] as? [[String : Any]] else{
                print("数据格式错误")
                finished(nil)
                return
            }
            //----缓存网络数据-----
            //将网络返回的数据，保存在本地数据库，以便以后使用
            saveCacheDate(array: array)
            //返回网络数据
            finished(array)
        }
        
        
    }
    
    /// 检查本地数据库中是否存在需要的数据
    /// - Parameters:
    ///   - since_id: 下拉刷新
    ///   - max_id: 上拉刷新
    private class func checkCacheDate(since_id: Int, max_id: Int) -> [[String : Any]]? {
        print("检查本地数据 \(since_id) \(max_id)")
        //用户id
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            print("用户没有登陆")
            return nil
        }
        
        //准备sql
        var sql = "SELECT * FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        if since_id > 0 {
            sql += "    AND statusId > \(since_id) \n"
        }
        else if max_id > 0 {
            sql += "    AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        //执行sql
        let array = SQLiteManager.sharedManager.execRecordSet(sql: sql)
        //遍历数组 dict["status"] json反序列化
        var arrayM = [[String : Any]]()
        for dict in array {
            let str = dict["status"] as! String
            let jsonData = str.data(using: .utf8)
            let result = try! JSONSerialization.jsonObject(with: jsonData!, options: [])
            //            print(result)
            //添加到数组
            arrayM.append(result as! [String : Any])
        }
        //如果没有查询到数据，会返回一个空的数组
        return arrayM
    }
    /// 将网络返回的数据保存至本地数据库
    /// - Parameter array: 网络返回的字典数组
    private class func saveCacheDate(array: [[String : Any]]) {
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
            
            print("数据插入完成")
        }
    }
}
