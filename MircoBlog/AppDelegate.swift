//
//  AppDelegate.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit
import AFNetworking
import Alamofire
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //设置输出
        QorumLogs.enabled = true
//        QorumLogs.test()
        //info以上的级别，添加问及说明，方便查找
        //最小日志界别
//        QorumLogs.minimumLogLevelShown = 4
        //测试的时候 限定输出的文件
//        QorumLogs.onlyShowThisFile(HomeTableViewController.self)
        
        //设置afn 通过afn发起网络请求时，在状态栏显示菊花加载
        // TODO: - 没反应
//        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        setupAppearance()
        //测试归档
//        QLShortLine()
//        QL2(UserAccountViewModel.sharedUserAccount.account!)
//        print(UserAccountViewModel.sharedUserAccount.account)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = defaultRootViewController
        window?.makeKeyAndVisible()
//        print(isNewVersion)
        //监听通知
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(WBSwitchRootViewControllerNotification), //通知名称，通知中心用来识别通知
            object: nil, //发送通知的对象，如果为nil，监听任何对象
            queue: nil) //nil是主线程
        { [weak self] (notification) in //闭包中使用的self都是weakself
//            print(Thread.current)
//            print(notification)
            //切换控制器
            let vc = notification.object != nil ? WelcomeViewController() : MainViewController()
            self?.window?.rootViewController = vc
        }
        
        return true
    }
    //应用程序进入后台
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //清除数据库缓存
        StatusDAL.clearDataCache()
    }
    deinit {
        //注销通知 --注销指定的通知
        NotificationCenter.default.removeObserver(self, //监听者
                                                  name: NSNotification.Name(WBSwitchRootViewControllerNotification), //监听的通知
                                                  object: nil) //发送通知的对象
    }
    
    ///设置全局外观，会在AppDelegate中设置所有需要控件的全局外观
    private func setupAppearance() {
        //修改导航栏全局外观 要在控件创建之前设置，一经设置全局有效
        UINavigationBar.appearance().tintColor = WBAppearanceTintColor
        
        //设置tabbar 图片渲染颜色
        UITabBar.appearance().tintColor = WBAppearanceTintColor
    
    }

}
//MARK: - 界面切换代码
extension AppDelegate {
    ///启动的根视图控制器
    private var defaultRootViewController: UIViewController {
        //新版本永远显示新特性，已登录显示欢迎
        //1.判断是否登录
        if UserAccountViewModel.sharedUserAccount.userLogon {
            return isNewVersion ? NewFeatureCollectionViewController() : WelcomeViewController()
        }
        //2.没有登陆返回主控制器
        return isNewVersion ? NewFeatureCollectionViewController() : MainViewController()
    }
    private var isNewVersion: Bool {
        //当前的版本
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let version = Double(currentVersion)!
//        print("当前版本\(version)")
        //之前的版本
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxViersion = UserDefaults.standard.double(forKey: sandboxVersionKey)
//        print("之前版本\(sandboxViersion)")
        //保存当前版本
        UserDefaults.standard.setValue(version, forKey: "sandboxVersionKey")
        return version > sandboxViersion
    }
}
