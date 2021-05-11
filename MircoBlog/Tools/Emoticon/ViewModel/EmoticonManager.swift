//
//  EmoticonsViewModel.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//


import UIKit
//MARK: - 表情包管理器

class EmoticonManager {
    ///单例 只创建一次
    static let sharedManager = EmoticonManager()
    ///表情包模型
    lazy var packages = [EmoticonPackage]()
    //MARK: - 生成属性字符串
    ///将字符串转换成属性字符串
    func emoticonText(string: String, font: UIFont) -> NSAttributedString {
        let strM = NSMutableAttributedString(string: string)
        //准备正则表达式 []是关键字需要转义
        let pattern = "\\[.*?\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        //匹配多项内容
        let results = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        var count = results.count
        //倒着遍历查找到的范围
        while count > 0 {
            count -= 1
            let range = results[count].range(at: 0)
            //从字符串中获取表情子串
            let emStr = (string as NSString).substring(with: range)
            if let em = emoticonWithString(string: emStr) {
                //根据em建议一个图片表情文本
                let attText = EmoticonAttachment(emoticon: em).imageText(font: font)
                //替换属性字符串中的内容
                strM.replaceCharacters(in: range, with: attText)
            }
        }
        return strM
        
    }
    /// 根据表情字符串在表情包中查找对应的表情
    /// - Parameter string: 表情字符串
    /// - Returns: 表情模型
    private func emoticonWithString(string: String) -> Emoticon? {
        //遍历表情包数组
        for package in packages {
            //过滤emoticons数组，查找em.chs == string的表情模型
            //1.如果闭包有返回值，闭包代码只有一句，可以省略return
            //2.如果有参数，参数可以使用 $0,$1...替代
            if let emoticon = package.emoticons.filter({ $0.chs == string }).last {
                return emoticon
            }
        }
        return nil
    }
    
    //MARK: - 构造函数
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
