//
//  NetworkTools.swift
//  swift封装fn
//
//  Created by apple on 2021/4/7.
//

import UIKit
import AFNetworking
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
    private var tokenDict: [String: Any]? {
        
        //判断token是否有效
        if let token = UserAccountViewModel.sharedUserAccount.accessToken {
//            print(token)
//            print(UserAccountViewModel.sharedUserAccount.account?.uid)
            return ["access_token" : token]
        }
        return nil
    }
    
}
//MARK: - 微博数据相关方法
extension NetworkTools {
    
    /// 加载微博数据
    /// - Parameter finished: 完成回调
    /// - see: [https://open.weibo.com/wiki/2/statuses/home_timeline](https://open.weibo.com/wiki/2/statuses/home_timeline)
    func loadStatus(finished: @escaping SSRequestCallBack) {
        //1.获取token字典
        guard let params = tokenDict else {
            //如果字典为nil，通知调用方，token无效
            
            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
            return
        }
        // 准备网络参数
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        //发起网络请求
        request(method: .GET, URLString: urlString, parameters: params, finished: finished)
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
        guard var params = tokenDict else {
            //如果字典为nil，通知调用方，token无效
            
            finished(nil, NSError(domain: "mzx.error", code: -1001, userInfo: ["message" : "token为空"]))
            return
        }
        let urlString = "https://api.weibo.com/2/users/show.json"
        params["uid"] = uid
        request(method: .GET, URLString: urlString, parameters: params, finished: finished)
        
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
}
