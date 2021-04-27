//
//  PhotoBrowserAnimator.swift
//  MircoBlog
//
//  Created by apple on 2021/4/26.
//

import UIKit
//MARK: - 展现动画协议
protocol PhotoBrowserPresentDelegate: NSObjectProtocol {
    
    /// 指定indexPath对应的ImageView，用来做动画效果
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView 
    ///动画转场起始位置
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect
    ///动画转场目标位置
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect
}

//MARK: - 解除动画协议
protocol PhotoBrowserDismissDelegate: NSObjectProtocol {
    ///解除转场图像视图
    func imageViewForDismiss() -> UIImageView
    ///解除转场的图像索引
    func indexPathForDismiss() -> IndexPath
}

//MARK: - 提供转场动画的代理
class PhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {
    ///展现代理
    weak var presentDelegate: PhotoBrowserPresentDelegate?
    ///解除代理
    weak var dismissDelegate: PhotoBrowserDismissDelegate?
    ///动画图像的索引
    var indexPath: IndexPath?
    ///是否modal展现的标记
    private var isPresented = false
    
    ///  设置代理相关参数
    /// - Parameters:
    ///   - presentDelegate: 展现代理对象
    ///   - indexPath: 图像索引
    func setDelegateParams(presentDelegate: PhotoBrowserPresentDelegate,
                           indexPath: IndexPath,
                           dismissDelegate: PhotoBrowserDismissDelegate) {
        
        self.presentDelegate = presentDelegate
        self.indexPath = indexPath
        self.dismissDelegate = dismissDelegate
    }
    ///返回提供modal展现的动画的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    ///提供dismiss的动画对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
}
//MARK: - UIViewControllerAnimatedTransitioning 实现具体的动画方法
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    ///动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    /// 实现具体的动画效果 一旦实现了此方法，所有的动画代码都交给程序员负责
    /// - Parameter transitionContext: 转场动画的上下文 提供动画所需要的素材
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //自动布局系统不会对根视图对任何约束
        //1.容器视图，会将modal要展现的视图包装在容器视图中，存放的视图要显示，必须自己指定大小，不会通过自动布局填满屏幕
        //2.viewController fromVC/toVC
        /**
         let fromVC = transitionContext.viewController(forKey: .from)
         print(fromVC) //<MircoBlog.MainViewController: 0x7ff854808c00>
         let toVC = transitionContext.viewController(forKey: .to)
         print(toVC) //<MircoBlog.PhotoBrowserViewController: 0x7ff8544613f0>
         */
        //3.view fromView / toView
        /**
         let fromView = transitionContext.view(forKey: .from)
         print(fromView) //nil
         let toView = transitionContext.view(forKey: .to)
         print(toView) //<UIView: 0x7fdaa0458a50; frame = (0 0; 434 736); layer = <CALayer: 0x60000227f360>>
         */
        //4.completeTransition: 无论转场是否被取消都必须被调用，否则系统不会做其他事件处理
        isPresented ? presentAnimation(using: transitionContext) : dimissAnimation(using: transitionContext)
    }
    ///解除转场动画
    private func dimissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentDelegate = presentDelegate,
              let dismissDelegate = dismissDelegate else {
            return
        }
        //获取要dismiss的控制器视图
        let fromView = transitionContext.view(forKey: .from)
        fromView?.removeFromSuperview()
        //获取图像视图
        let iv = dismissDelegate.imageViewForDismiss()
        //添加到容器视图
        transitionContext.containerView.addSubview(iv)
        //获取dismiss的indexPath
        let indexPath = dismissDelegate.indexPathForDismiss()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            //让iv运动到起始位置
            iv.frame = presentDelegate.photoBrowserPresentFromRect(indexPath: indexPath)
        } completion: { (result) in
            //将fromview从父视图中删除
            iv.removeFromSuperview()
            //告诉系统动画完成
            transitionContext.completeTransition(result)
        }

    }
    ///展现动画
    private func presentAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentDelegate = presentDelegate, let indexPath = indexPath else {
            return
        }
        //目标视图
        //获取modal要展现的控制器的根视图
        let toView = transitionContext.view(forKey: .to)
        //将视图添加到容器视图中
        transitionContext.containerView.addSubview(toView!)
        
        //图像视图
        //能够参与动画的图像视图/起始位置/目标位置
        let iv = presentDelegate.imageViewForPresent(indexPath: indexPath)
        //指定图像视图的位置
        iv.frame = presentDelegate.photoBrowserPresentFromRect(indexPath: indexPath)
        //将图像视图添加到容器视图
        transitionContext.containerView.addSubview(iv)

        toView?.alpha = 0
        
        //开始动画
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            iv.frame = presentDelegate.photoBrowserPresentToRect(indexPath: indexPath)
            toView?.alpha = 1
        } completion: { (result) in
            //删除图像视图
            iv.removeFromSuperview()
            //告诉系统转场动画完成
            transitionContext.completeTransition(result)
        }
        
    }
}
