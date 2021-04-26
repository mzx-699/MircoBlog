//
//  Common.swift
//  MircoBlog
//
//  Created by apple on 2021/4/7.
//
//提供全局共享属性或者方法，类似pch
import UIKit
//MARK: - 全局通知定义
///切换根视图控制器通知 一定要够长要有前缀
let WBSwitchRootViewControllerNotification = "WBSwitchRootViewControllerNotification"
///选中照片通知
let WBStatusSelectedPhotoNotification = "WBStatusSelectedPhotoNotification"
///选中照片的索引键
let WBStatusSelectedPhotoIndexPathKey = "WBStatusSelectedPhotoIndexPathKey"
///选中照片的链接数组键
let WBStatusSelectedPhotoURLsKey = "WBStatusSelectedPhotoURLsKey"
///全局外观渲染颜色 -> 延展出皮肤管理类
let WBAppearanceTintColor = UIColor.orange

//MARK: - 自定义关键字
//MARK: - 全局函数 可以直接使用

/// 延迟操作，在主线程执行
/// - Parameters:
///   - delta: 延迟时间
///   - callFunc: 回调闭包
func delay(delta: Double, callFunc: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delta) {
        callFunc()
    }
}
