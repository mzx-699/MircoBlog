//
//  StatusListViewModel.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import Foundation

///微博数据列表模型 - 封装网络方法
class StatusListViewModel {
    //微博数据数组
    lazy var statusList = [StatusViewModel]()
    
    ///加载网络数据
    func loadStatus(finished: @escaping (_ isSuccessed: Bool)->()) {
        
        NetworkTools.sharedTools.loadStatus { (result, error) in
            if error != nil {
                print("出错了\(error!)")
                finished(false)
                return
            }
            //判断数据结构是否正确
            guard let array = (result as! [String : Any])["statuses"] as? [[String : Any]] else{
                print("数据格式错误")
                finished(false)
                return
            }
            //遍历字典数据，字典转模型
            //1.可变的数据
            var dataList = [StatusViewModel]()
            //遍历数据
            for dict in array {
                dataList.append(StatusViewModel(status: Status(dict: dict)))
            }
            //2.拼接数据
            self.statusList = dataList + self.statusList
            
            //完成回调
            finished(true)
            
        }
    }
}
