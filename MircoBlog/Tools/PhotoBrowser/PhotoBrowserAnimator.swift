//
//  PhotoBrowserAnimator.swift
//  MircoBlog
//
//  Created by apple on 2021/4/26.
//

import UIKit

class PhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {
    //返回提供modal展现的动画的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
//MARK: - UIViewControllerAnimatedTransitioning 实现具体的动画方法
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    ///动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    /// 实现具体的动画效果 一旦实现了此方法，所有的动画代码都交给程序员负责
    /// - Parameter transitionContext: 转场动画的上下文 提供动画所需要的素材
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("animateTransition")
    }
}
