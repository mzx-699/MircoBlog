//
//  StatusViewModel.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import UIKit
///微博视图模型 - 处理单条微博的业务逻辑
class StatusViewModel: CustomStringConvertible {
    ///微博的模型
    var status: Status
    
    ///用户头像 URL
    var userProFileUrl: URL {
        return URL(string: status.user?.profile_image_url ?? "")!
    }
    ///占位头像
    var userDefaultIconView: UIImage {
        return UIImage(named: "avatar_default_big")!
    }
    //使用uiimage imagenamed创建的图像，缓存由系统管理，程序员不能直接释放
    //适用于小的图片素材
    //注意高清大图不能这样
    ///会员图标
    var userMemeberImage: UIImage? {
        //根据mbrank 生成头像
        if status.user?.mbrank ?? 0 > 0 && status.user?.mbrank ?? 0 < 7 {
            return UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")!
        }
        return nil
    }
    ///用户认证图标
    ///认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var userVipImage: UIImage? {
        switch (status.user?.verified_type ?? -1) {
        case 0:
            return UIImage(named: "avatar_vip")
        case 2, 3, 5:
            return UIImage(named: "avatar_enterprise_vip")
        case 220:
            return UIImage(named: "avatar_grassroot")
        default:
            return nil
        }
        
    }
    ///缩略图URL数组 设置成存储型属性
    var thumbnailUrls: [URL]?
    
    ///构造函数，使其可选
    init(status: Status) {
        self.status = status
        //根据模型生成缩略图数组
        if status.pic_urls!.count > 0 {
            //创建缩略图数据
            thumbnailUrls = [URL]()
            //遍历字典数组 数组如果可选，不允许遍历，数组是通过下标来检索数据的
            for dict in status.pic_urls! {
                //因为字典是按照key为取值，如果key错误，会返回nil
                let url = URL(string: dict["thumbnail_pic"]!)
                //相信服务器返回的url字符串一定能生成
                thumbnailUrls?.append(url!)
            }
        }
    }
    var description: String {
        //strng到nstring array到nsarray dic到nsdic as不需要加!?
        return self.status.description + "配图数组\(thumbnailUrls ?? [] as Array)"
    }
}
