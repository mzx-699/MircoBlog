//
//  OAtuhViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/7.
//

import UIKit
import WebKit
class OAtuhViewController: UIViewController {
    
    private lazy var webView = WKWebView()
    //MARK: - 截图字符串的方法
    private func getStr(str: String, startStrOne: String) -> String {
        let range = str.range(of: startStrOne)!
        //不包含
        let location = str.distance(from: str.startIndex, to: range.upperBound)
        let subStr = str.suffix(str.count - location)
        let startIndex = subStr.startIndex
        let code = str[startIndex ..< str.endIndex]
        return String(code)
    }
    
    //MARK: - 监听方法
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    ///自动填充用户名和密码 - web注入（以代码的方式向web页面添加内容）
    @objc private func autoFill() {
        let js = "document.getElementById('loginName').value = 'mazhixiang12345@163.com';" +
            "document.getElementById('loginPassword').value = '978653881';"
        //让webView执行js
        webView.evaluateJavaScript(js) { (response, error) in
            if error != nil {
                print(error!)
            }
            print(response ?? "nil")
        }
    }
    //MARK: - 设置界面
    override func loadView() {
        view = webView
        //设置代理
        webView.navigationDelegate = self
        //设置导航栏
        title = "登陆新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: .plain, target: self, action: #selector(autoFill))
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //背景颜色为nil，会影响渲染效率
//        view.backgroundColor = UIColor.white
        webView.load(URLRequest(url: NetworkTools.sharedTools.oauthURL as URL))
    }
    

}
//MARK: - WKNavigationDelegate
extension OAtuhViewController: WKNavigationDelegate {
    //如果ios的代理方法中返回bool，通常返回true正常工作
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //目标：如果是百度就不加载
//        print("hello")
//        print(navigationAction.request.url)
        //1.判断访问的主机是否是www.baidu.com
        guard let url = navigationAction.request.url, url.host == "www.baidu.com" else{
            decisionHandler(.allow)
//            print((navigationAction.request.url?.host)!)
            return
        }
        //2.从百度地址的url中提取 code=是否存在
        guard let query = url.query, query.hasPrefix("code=") else {
            print("取消授权")
//            print("code=")
            decisionHandler(.cancel)
            return
        }
        //3.从query字符串提取授权码
        let code = getStr(str: query, startStrOne: "code=")
        print(code)
        //4.加载accessToken
        NetworkTools.sharedTools.loadAccessToken(code: code) { (result, error) in
            if error != nil {
                print("出错了 \(error!)")
                return
            }
            /**
             {
                 "access_token" = "2.00vTo1xCg1d3UD03b295f1e4YYU4GC";
                 "expires_in" = 157679999;
                 isRealName = true;
                 "remind_in" = 157679999;
                 uid = 2709030103;
             }
             */
            //swift中任何anyobjct在使用前，必要转换类型 -> as ?/! 类型
//            print(result!)
            let account = UserAccount(dict: result as! Dictionary<String, Any>)
//            print(account)
            self.loadUserInfo(account: account)
            
        }
        decisionHandler(.cancel)
    }
    
    private func loadUserInfo(account: UserAccount) {
        NetworkTools.sharedTools.loadUserInfo(uid: account.uid!, accessToken: account.access_token!) { (result, error) in
            if error != nil {
                print("出错了 \(error!)")
                return
            }
            //如果使用if/guard as 统统使用?
            //以下做了两个判断
            //1.result 一定有内容
            //2.一定是字典
            guard let dict = result as? [String : Any] else {
                print("格式错误")
                return
            }
            //保存用户信息
            account.screen_name = dict["screen_name"] as? String
            account.avatar_large = dict["avatar_large"] as? String
            
            print(account)
        }
    }
}
