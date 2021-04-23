//
//  NetworkTools.swift
//  swift封装fn
//
//  Created by apple on 2021/4/7.
//

import UIKit
import AFNetworking
//实际开发中，在发现需要重构时，需要及时重构；出现了相同的代码
///枚举
enum SSRequestMethod: String {
    case GET = "GET"
    case POST = "POST"
}

//MARK: - 网络工具
class NetworkTools: AFHTTPSessionManager {
    

    
    //MARK: - 应用程序信息
    private let appKey: String = "3197082990"
    private let appSecret: String = "d23cef166f8c1b215e6c27544179f7dd"
    private let redirectUrl = "http://www.baidu.com"
    
    ///类似OC中的typeDefine 网络请求完成回调
    typealias SSRequestCallBack = (_ result: Any?, _ error: Error?) -> ()
    
    
    static let sharedTools: NetworkTools = { () -> NetworkTools in 
        let tools = NetworkTools(baseURL: nil)
        //设置反序列化数据格式 系统会自动将oc中的nsset转换成set
        tools.responseSerializer.acceptableContentTypes?.insert("text/html")
        return tools
    }()
    
    //返回token字典
//    private var tokenDict: [String: Any]? {
//
//        //判断token是否有效
//        if let token = UserAccountViewModel.sharedUserAccount.accessToken {
////            print(token)
////            print(UserAccountViewModel.sharedUserAccount.account?.uid)
//            return ["access_token" : token]
//        }
//        return nil
//    }
    
}
//MARK: - 发布微博
extension NetworkTools {
    // TODO: - 接口问题暂时发不了
    /// 发布微博
    /// - Parameters:
    ///   - status: 微博文本
    ///   - image: 微博配图
    ///   - finished: 完成回调
    ///   - see: [https://open.weibo.com/wiki/2/statuses/share](https://open.weibo.com/wiki/2/statuses/share)
    func sendStatus(status: String, image: UIImage?, finished: @escaping SSRequestCallBack) {
        //1.获取token字典
//        guard var params = tokenDict else {
//            //如果字典为nil，通知调用方，token无效
//
//            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
//            return
//        }
        //创建参数字典
        var params: [String : Any]? = [String : Any]()
        //设置参数
        params!["status"] = status
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        //判断是否上传图片
        if image == nil {
            
//            print(params!)
            //发起网络请求
            tokenRequest(method: .POST, URLString: urlString, parameters: &params, finished: finished)
        }
        else {
            let data = UIImage.pngData(image!)()
//            print(params)
            upload(URLString: urlString, data: data!, name: "pic", parameters: &params, finished: finished)
        }

    }
}
//MARK: - 微博数据相关方法
extension NetworkTools {
    
    /// 加载微博数据
    /// since_id    false    int64    若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    /// max_id    false    int64    若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    /// - Parameter finished: 完成回调
    /// - see: [https://open.weibo.com/wiki/2/statuses/home_timeline](https://open.weibo.com/wiki/2/statuses/home_timeline)
    func loadStatus(since_id: Int, max_id: Int, finished: @escaping SSRequestCallBack) {
        //创建参数字典
        var params: [String : Any]? = [String : Any]()
        //判断是否下拉
        if since_id > 0 {
            params!["since_id"] = since_id
        }
        else if max_id > 0 { //上拉
            //-1防止加载重复微博
            params!["max_id"] = max_id - 1
            params!["count"] = 10
        }
        // 准备网络参数
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        //发起网络请求
        tokenRequest(method: .GET, URLString: urlString, parameters: &params, finished: finished)
    }
}
//MARK: - 用户相关方法
extension NetworkTools {
    
    //https://api.weibo.com/2/users/show.json
    /// 加载用户信息
    /// - Parameters:
    ///   - uid: uid
    ///   - accessToken: accessToken
    ///   - finished: 完成回调
    ///   - see: [https://open.weibo.com/wiki/2/users/show](https://open.weibo.com/wiki/2/users/show)
    func loadUserInfo(uid: String, finished: @escaping SSRequestCallBack) {
        //1.获取token字典
        //创建参数字典
        var params: [String : Any]? = [String : Any]()
        let urlString = "https://api.weibo.com/2/users/show.json"
        params!["uid"] = uid
        tokenRequest(method: .GET, URLString: urlString, parameters: &params, finished: finished)
        
    }
}
//MARK: - OAuth相关方法
extension NetworkTools {
    
    ///OAuth授权URL
    /// - see:  [https://open.weibo.com/wiki/Oauth2/authorize](https://open.weibo.com/wiki/Oauth2/authorize)
    var oauthURL: URL {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(appKey)&redirect_uri=\(redirectUrl)"
        print(urlString)
        return URL(string: urlString)!
    }

    ///加载AccessToken
    func loadAccessToken(code: String, finished: @escaping SSRequestCallBack) {
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let params = ["client_id": appKey,
            "client_secret": appSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUrl]
        request(method: .POST, URLString: urlString, parameters: params, finished: finished)
        //测试返回的数据内容，AFN默认的响应格式是JSON，会直接反序列化
        //确认数据格式问题
        //1.设置相应数据格式是二进制
        //2.发起网络请求
//        responseSerializer = AFHTTPResponseSerializer()
//        post(urlString, parameters: params, headers: nil, progress: nil) { (_, result) in
//            let json = String(data: result as! Data, encoding: .utf8)
//            print(json)
//        } failure: { (_, nil) in
//            print("failure")
//        }

    }
}
//MARK: - 封装AFN
extension NetworkTools {
    
    /// 向parameters字典中追加token参数
    /// - Parameter parameters: 参数字典
    /// - Returns: 是否追加成功
    //关于函数参数，在调用时候，会做一次copy，在函数内部修改参数值，不会影响到外部的数值
    //inout关键字，相当于在oc中传递对象的地址
    private func appendToken(parameters: inout [String: Any]?) -> Bool {
        //设置token参数  将token添加到parameters中
        //判断token是否有效
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {

            return false
        }
        if parameters == nil {
            parameters = [String : Any]()
        }
        //设置token
        parameters!["access_token"] = token
        return true
    }
    /// 只用token进行网络请求
    private func tokenRequest(method: SSRequestMethod, URLString: String, parameters: inout [String: Any]?, finished: @escaping SSRequestCallBack) {
        //如果追加token失败，直接返回
        if !appendToken(parameters: &parameters) {
            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
            return
        }
//        //设置token参数  将token添加到parameters中
//        //判断token是否有效
//        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
//            //token无效
//            //如果字典为nil，通知调用方，token无效
//            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
//            return
//        }
//        //设置字典
//        //判断参数字典是否有值
//        if parameters == nil {
//            parameters = [String : Any]()
//        }
//        parameters!["access_token"] = token

        //发起网络请求
        request(method: method, URLString: URLString, parameters: parameters, finished: finished)
    }
    func request(method: SSRequestMethod, URLString: String, parameters: [String: Any]?, finished: @escaping SSRequestCallBack) {
        //定义成功回调
        let success = { (task: URLSessionDataTask, result: Any?) in
            finished(result, nil)
            
        }
        //定义失败回调
        let failure = { (task: URLSessionDataTask?, error: Error) in
            print(error)
            finished(nil, error)
        }
        
        if method == .GET {
            self.get(URLString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        }
        else {
            self.post(URLString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        }


    }
    
    private func upload(URLString: String, data: Data, name: String, parameters: inout [String: Any]?, finished: @escaping SSRequestCallBack) {
        
        //如果追加token失败，直接返回
        if !appendToken(parameters: &parameters) {
            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
            return
        }
        
        post(URLString, parameters: parameters, headers: nil) { (formData) in
            //data 要上传的二进制数据，
            //name 服务器定义的字段名字 - 后台接口文档会显示；
            //fileName是保存在服务器的文件名，但是：通常可以乱写，后台会做后续的处理，根据上传的文件，生成缩略图，中等图，高清图，是http协议定义的属性
            //mimeType/contentType 客户端告诉服务器，二进制数据的准确类型 - 大类型/小类型 image/ipg,image/git,image/png; text/plain,text/html, application/json 如果不想告诉服务器准确类型 application/octet-stream
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
        } progress: { (_) in
            
        } success: { (_, result) in
            finished(result, nil)
        } failure: { (_, error) in
            finished(nil, error)
        }
    

    }
}
