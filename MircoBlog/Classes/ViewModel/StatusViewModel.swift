//
//  StatusViewModel.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import UIKit
///微博视图模型 - 处理单条微博的业务逻辑
class StatusViewModel {
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
    ///构造函数，使其可选
    init(status: Status) {
        self.status = status
    }
}
