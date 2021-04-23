//
//  EmoticonsViewModel.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//

import Foundation
//MARK: - 表情包管理器

class EmoticonManager {
    ///单例 只创建一次
    static let sharedManager = EmoticonManager()
    ///表情包模型
    lazy var packages = [EmoticonPackage]()
    private init() {
        loadPlist()
    }
    
    ///从emoticons.plist加载表情包数据 -> 取到不同的目录 -> 找各自的info.plist -> packages存储id cn和emoticons -> 取emoticos
    private func loadPlist() {
        //添加最近的分组
        packages.append(EmoticonPackage(dict: ["group_name_cn" : "最近"]))
        //加载emoticons.plist
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        //加载字典
        let dict = NSDictionary(contentsOfFile: path!) as! [String : Any]
        //从字典中获得id的数组 --- 直接获得字典数组中的key对应的数组
        let array = (dict["packages"] as! NSArray).value(forKey: "id")
        //遍历id数组，加载info.plist
        for id in array as! [String] {
            loadInfoPlist(id: id)
        }
        print(packages)
    }
    
    /// 加载每一个id目录下的info.plist
    /// - Parameter id: 文件名
    private func loadInfoPlist(id: String) {
        //建立路径
        let path = Bundle.main.path(forResource: "info.plist", ofType: nil, inDirectory: "Emoticons.bundle/\(id)")!
        //加载字典 一个独立的表情包
        let dict = NSDictionary(contentsOfFile: path) as! [String : Any]
        //字典转模型 追加到packages数组
        packages.append(EmoticonPackage(dict: dict))
    }
}
