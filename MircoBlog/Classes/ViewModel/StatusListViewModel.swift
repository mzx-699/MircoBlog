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

    /// 加载网络数据
    /// - Parameters:
    ///   - isPullup: 是否上拉刷新
    ///   - finished: 完成回调
    func loadStatus(isPullup: Bool, finished: @escaping (_ isSuccessed: Bool)->()) {
        //下拉刷新 比数组中第一条微博大的id就是新的微博
        //0的时候加载20条数据
        let since_id = isPullup ? 0 : statusList.first?.status.id ?? 0
        //上拉刷新 比数组中最后一条微博id小的微博
        let max_id = isPullup ? statusList.last?.status.id ?? 0 : 0
        // ---检查本地缓存数据----
        StatusDAL.checkCacheDate(since_id: since_id, max_id: max_id)
        NetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id) { (result, error) in
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
            //----缓存网络数据-----
            StatusDAL.saveCacheDate(array: array)
            //遍历字典数据，字典转模型
            //1.可变的数据
            var dataList = [StatusViewModel]()
            //遍历数据
            for dict in array {
                dataList.append(StatusViewModel(status: Status(dict: dict)))
            }
            //2.拼接数据
            //判断是否是上拉刷新
            if max_id > 0 {
                self.statusList += dataList
            }
            else {
                self.statusList = dataList + self.statusList
            }
//            print("刷新出\(dataList.count)")
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
            
            //refreshCached 第一次发起网络请求，把缓存的图片一个hash值发送给服务器，服务器对比hash值，如果和服务器内容一致，服务器返回的状态码304，表示服务器内容没有变化；如果不是304，会再次发起网络请求，获得更新后的内容，造成调度组不匹配
            //下载图像，缓存自动完成
            /**
                SDWebImageDownloaderLowPriority = 1 << 0,
                 SDWebImageDownloaderProgressiveDownload = 1 << 1,  // 带有进度
                 SDWebImageDownloaderUseNSURLCache = 1 << 2,  // 使用URLCache
                 SDWebImageDownloaderIgnoreCachedResponse = 1 << 3,  // 不缓存响应
                 SDWebImageDownloaderContinueInBackground = 1 << 4,  // 支持后台下载
                 SDWebImageDownloaderHandleCookies = 1 << 5,   // 使用Cookies
                 SDWebImageDownloaderAllowInvalidSSLCertificates = 1 << 6,  // 允许验证SSL
                 SDWebImageDownloaderHighPriority = 1 << 7,      // 高权限
                 SDWebImageDownloaderScaleDownLargeImages = 1 << 8,  // 裁剪大图片
             */
            SDWebImageDownloader.shared.downloadImage(with: url, options: [.handleCookies], progress: nil) { (image, _, error, _) in
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
//            SDWebImageDownloader.shared.downloadImage(with: url) { (image, _, error, _) in
//                if error != nil {
//                    print(error!)
//                }
//                //下载单张图片
//                if let img = image,
//                   let data = UIImage.pngData(img)() {
//                    //累加二进制数据长度
//                    dataLength += data.count
//                }
//                group.leave()
//            }
            
        }      
        //监听调度组完成
        group.notify(queue: DispatchQueue.main) {
//            print("缓存完成\(dataLength / 1024)")
            //完成回调 控制器才开始刷新表格
            finished(true)
        }

    }
}
