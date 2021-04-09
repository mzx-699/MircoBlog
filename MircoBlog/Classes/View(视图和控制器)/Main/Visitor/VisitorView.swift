//
//  VisitorView.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit
import SnapKit


///访客视图-处理用户未登陆的访客视图
class VisitorView: UIView {

    //MARK: - 设置视图信息
    ///设置属兔信息 imageName 图片名称，首页设置为nil；title 消息文字
    func setupInfo(imageName: String?, title: String) {
        messageLabel.text = title
        //如果图片名称为nil，说明是首页，直接返回
        guard imageName != nil else {
            //播放动画
            startAnim()
            return
        }
        iconView.image = UIImage(named: imageName!)
        //隐藏房子
        homeIconView.isHidden = true
        //将mask移动到底层
        sendSubviewToBack(maskIconView)
    }
    ///开启首页转轮动画
    private func startAnim() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 20
        //用在不断重复的动画上，当动画绑定的图层对应的视图被销毁，动画会自动被销毁
        anim.isRemovedOnCompletion = false
        //添加到图层
        iconView.layer.add(anim, forKey: nil)
    }
    //MARK: - 构造函数
    //是UIView的指定构造函数
    //使用纯代码开发使用的init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    //initWithCoder 使用sb/xib开发的时候加载的函数
    required init?(coder: NSCoder) {
        //如果sb开发调用这个视图会直接崩溃
        //阻止使用sb使用当前自定义视图
        //如果只希望当前视图被纯代码的方式加载，可以使用下面的方法，阻止sb
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        setupUI()
    }
    //MARK: - 懒加载控件
    //使用image构造函数创建的，imageview默认的就是image的大小
    ///图标
    private lazy var iconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_image_smallicon")
    ///mask
    private lazy var maskIconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_mask_smallicon")
    ///房子
    private lazy var homeIconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_image_house")
    ///标签
    private lazy var messageLabel: UILabel = UILabel(title: "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜")
    
    ///按钮
    lazy var registerButton: UIButton = UIButton(title: "注册", color: UIColor.orange, imageName: "common_button_white_disable")
    lazy var loginButton: UIButton = UIButton(title: "登陆", color: UIColor.darkGray, imageName: "common_button_white_disable")

}
//MARK: - 设置界面
extension VisitorView {
    ///设置页面
    private func setupUI() {
        //1.添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        //2.设置自动布局
        //图标
        iconView.snp.makeConstraints { (make) in
            //指定centerX属性等于‘参照对象’参照属性值
            //offset指定相对视图约束的偏移量
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-50)
        }
        //小房子

        homeIconView.snp.makeConstraints { (make) in
            make.center.equalTo(iconView.snp.center)
        }
        //标签
        messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconView.snp.centerX)
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.width.equalTo(230)
            make.height.equalTo(36)
        }
        //注册按钮
        registerButton.snp.makeConstraints { (make) in
            make.left.equalTo(messageLabel.snp.left)
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        //登陆按钮
        loginButton.snp.makeConstraints { (make) in
            make.right.equalTo(messageLabel.snp.right)
            make.top.equalTo(registerButton.snp.top)
            make.width.equalTo(registerButton.snp.width)
            make.height.equalTo(registerButton.snp.height)
        }
        //mask
        maskIconView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(registerButton.snp.bottom)
        }

        //设置背景颜色 灰度图 r=b=g UI元素中，大多数都使用灰度图或者纯色图（安全色）
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
        
    }
    
    private func setUIDemo() {
        //2.设置自动布局
        //添加约束需要添加到父视图上
        //子视图最好有一个统一的参照物
        //translatesAutoresizingMaskIntoConstraints 默认值是true 支持使用setFrame的方式设置控件位置；fale支持使用自动布局设置控件位置
//        for v in subviews {
//            v.translatesAutoresizingMaskIntoConstraints = false
//        }
//        //图标
//        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
//        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -50))
        //        //小房子
        //        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        //        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        //        //标签
        //        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: iconView, attribute: .centerX, multiplier: 1.0, constant: 0))
        //        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: iconView, attribute: .bottom, multiplier: 1.0, constant: 16))
        //        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 230))
        //        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36))
        //        //注册按钮
        //        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .left, relatedBy: .equal, toItem: messageLabel, attribute: .left, multiplier: 1.0, constant: 0))
        //        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal, toItem: messageLabel, attribute: .bottom, multiplier: 1.0, constant: 16))
        //        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        //        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36))
        //        //登陆
        //        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .right, relatedBy: .equal, toItem: messageLabel, attribute: .right, multiplier: 1.0, constant: 0))
        //        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .top, relatedBy: .equal, toItem: messageLabel, attribute: .bottom, multiplier: 1.0, constant: 16))
        //        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        //        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36))
        //        //mask
        //        //VFL可视化格式语言
        //        //h水平方向 V垂直方向 ｜边界 []包装控件 views字典 [名字：控件名] - VFL字符串中表示控件的字符串
        //        //metrics 字典[名字：NSNumber] - VFL中字符串表示某一个数值
        //mask水平方向0
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[mask]-0-|", options: [], metrics: nil, views: ["mask" : maskIconView]))
        //mask垂直方向上面0，下面-36
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mask]-(btnHeight)-[regButton]", options: [], metrics: ["btnHeight" : -36], views: ["mask" : maskIconView, "regButton" : registerButton]))
        //
        //        //设置背景颜色 灰度图 r=b=g UI元素中，大多数都使用灰度图或者纯色图（安全色）
        //        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
}
