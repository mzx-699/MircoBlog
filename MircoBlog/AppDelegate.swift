//
//  AppDelegate.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        //测试归档
//        print(UserAccountViewModel.sharedUserAccount.account)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    ///设置全局外观，会在AppDelegate中设置所有需要控件的全局外观
    private func setupAppearance() {
        //修改导航栏全局外观 要在控件创建之前设置，一经设置全局有效
        UINavigationBar.appearance().tintColor = WBAppearanceTintColor
        
        //设置tabbar 图片渲染颜色
        UITabBar.appearance().tintColor = WBAppearanceTintColor
    
    }

}

