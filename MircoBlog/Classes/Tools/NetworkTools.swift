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
