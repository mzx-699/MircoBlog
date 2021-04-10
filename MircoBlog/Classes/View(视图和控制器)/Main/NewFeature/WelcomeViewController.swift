//
//  WelcomeViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/9.
//

import UIKit
import SDWebImage
class WelcomeViewController: UIViewController {
    
    //设置界面的视图层次结构
    override func loadView() {
        //直接使用背景图像作为根视图，不用关心图像的缩放问题
        view = backImageView
        setupUI()
    }
    //视图加载完成之后的后续处理，设置数据
    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.avatarUrl, placeholderImage: UIImage(named: "avatar_default_big"), options: .delayPlaceholder, progress: nil, completed: nil)
        
    }
    //完全出现之后再显示动画
    //视图已经显示，处理动画/键盘
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //1. 更改约束
        //更新已经设置过的约束
        /**
         使用自动布局开发，有一个原则
         所有使用约束设置位置的控件，不要再设置frame
         原因：自动布局系统会根据设置的约束，自动设置控件的frame
         如果程序员主动修改frame，会引起自动布局系统计算错误
         工作原理：当一个运行循环启动，自动布局系统会收集所有的约束变化，在运行循环结束前，调用layoutSubviews统一设置frame
         如果希望某些约束提前更新，使用layoutIfNeed，让自动布局系统，提前更新当前的手机到的约束变化
         */
        iconView.snp.updateConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-view.bounds.height + 200)
        }
        
        //2.动画
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: []) {
            //自动布局的动画
            //修改所有可动画属性
            //所有子控件加到父视图上，更新父视图产生动画
            self.view.layoutIfNeeded()
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.8) {
                self.welcomeLabel.alpha = 1
            } completion: { (_) in
                //发送通知
                NotificationCenter.default.post(name: NSNotification.Name(WBSwitchRootViewControllerNotification), object: nil)
//                print("发送通知")
            }

        }

    }
    //MARK: - 懒加载
    ///背景图
    private lazy var backImageView: UIImageView = UIImageView(imageName: "ad_background")
    ///头像
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(imageName: "avatar_default_big")
        //设置圆角
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        return imageView
    }()
    //如果构造函数带默认值，创建时可以任意删减
    ///文字
    private lazy var welcomeLabel: UILabel = UILabel(title: "欢迎归来", fontSize: 18)

}

//MARK: - 设置界面
extension WelcomeViewController {
    
    private func setupUI() {
        //添加控件
        view.addSubview(iconView)
        view.addSubview(welcomeLabel)
        //自动布局
        iconView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            //乘积是只读属性，创建之后不能修改
            make.bottom.equalTo(view.snp.bottom).offset(-200)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        welcomeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconView)
            make.top.equalTo(iconView.snp.bottom).offset(16)
        }
        welcomeLabel.alpha = 0
    }
}
