//
//  SQLiteManager.swift
//  FMDB
//
//  Created by apple on 2021/4/28.
//

import Foundation
///数据库名称
private let dbName = "status.db"
class SQLiteManager {
    ///单例
    static let sharedManager = SQLiteManager()
    ///全局数据库操作队列
    let queue: FMDatabaseQueue
    private init() {
        //数据库路径 全路径 可读可写
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path = (path as NSString).appendingPathComponent(dbName)
        print(path)
        //打开数据库 通过数据库队列进行操作
        //如果数据库不存在，会建立数据库，然后，再创建队列并且打开数据库；如果数据库存在，则直接打开数据库
        queue = FMDatabaseQueue(path: path)!
        createTable()
    }
    
    /// 执行sql
    /// - Parameter sql: sql
    /// - Returns: 返回字典数组
    func execRecordSet(sql: String) -> [[String : Any]] {
        //结果数组
        var array = [[String : Any]]()
        //同步执行数据库查询
        SQLiteManager.sharedManager.queue.inDatabase { (db) in
            print(Thread.current)
            guard let result = db.executeQuery(sql, withArgumentsIn: []) else {
                print("failed")
                return
            }
            
            while result.next() {
                //列数
                let colCount = result.columnCount
                //创建字典
                var dict = [String : Any]()
                //遍历每一列
                for col in 0..<colCount {
                    //列名
                    let name = result.columnName(for: col)!
                    //值
                    let obj = result.object(forColumnIndex: col)!
                    //设置字典
                    dict[name] = obj
                }
                //字典插入数组
                array.append(dict)
            }
        }
        return array
        
    }
    private func createTable() {
        //准备sql 只读 创建应用程序时，准备的素材
        let path = Bundle.main.path(forResource: "db.sql", ofType: nil)
        let sql = try! String(contentsOfFile: path!)
        queue.inDatabase { (db) in
            //单条语句
            //let result = db.executeUpdate(sql, withArgumentsIn: [])
            //多条语句 保证一次性可以创建多个数据表
            let result = db.executeStatements(sql)
            if result {
                print("success")
            }
            else {
                print("failed")
            }
        }
    }
}
