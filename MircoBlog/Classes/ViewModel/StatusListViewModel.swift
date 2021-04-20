//
//  StatusListViewModel.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import Foundation
import SDWebImage
///微博数据列表模型 - 封装网络方法
class StatusListViewModel {
    ///微博数据数组
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
//            print(self.statusList)
//            //完成回调
//            finished(true)
            //缓存单张图片
            self.cacheSingleImage(dataList: dataList, finished: finished)
        }
    }
    ///缓存单张图片
    private func cacheSingleImage(dataList: [StatusViewModel], finished: @escaping (_ isSuccessed: Bool)->()) {
        let group = DispatchGroup()
        var dataLength = 0
        //遍历视图模型数组
        for vm in dataList {
            if vm.thumbnailUrls?.count != 1 {
                continue
            }
            //获取url
            let url = vm.thumbnailUrls![0]
//            print("开始缓存图像\(url)")
            //入组，监听后续的block
            group.enter()
            //下载图像，缓存自动完成
            SDWebImageDownloader.shared.downloadImage(with: url) { (image, _, error, _) in
                if error != nil {
                    print(error!)
                }
                //下载单张图片
                if let img = image,
                   let data = UIImage.pngData(img)() {
                    //累加二进制数据长度
                    dataLength += data.count
                }
                group.leave()
            }
            
        }
        //监听调度组完成
        group.notify(queue: DispatchQueue.main) {
//            print("缓存完成\(dataLength / 1024)")
            //完成回调 控制器才开始刷新表格
            finished(true)
        }

    }
}
