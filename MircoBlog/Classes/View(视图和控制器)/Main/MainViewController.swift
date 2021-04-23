//
//  MainViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//
/**
 监听方法放在最上面
 私有控件或者属性最下面
 函数说明三个斜杠注释
 */
import UIKit

class MainViewController: UITabBarController {
    
    //MARK: - 监听方法
    //点击撰写按钮方法
    //如果单纯使用private 运行循环无法正确发送消息，导致崩溃
    //如果使用@objc修饰保证运行循环能够发送此消息
    @objc private func clickComposedButton() {
//        print("点我了")
        //判断用户是否登陆
        let vc: UIViewController
        if UserAccountViewModel.sharedUserAccount.userLogon {
            vc = ComposeViewController()
        }
        else {
            vc = OAtuhViewController()
            
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    //MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        //仅加载数据，并不显示
        //添加控制器，并不会创建tabbar的按钮
        //懒加载无处不在，所有控件都是延迟创建
        addChildViewControllers()
        setupComposedButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        //视图显示的时候才会添加子控制器
        //才会创建tabbar中所有控制器对应的按钮
        //所以先viewdidload创建按钮后，再创建tabbar上的按钮
        super .viewWillAppear(animated)
        //将撰写按钮弄到最前面
        tabBar.bringSubviewToFront(composedButton)
    }
    //MARK: - 懒加载控件
    private lazy var composedButton: UIButton = UIButton(
        imageName: "tabbar_compose_icon_add",
        backImageName: "tabbar_compose_button")


}
//MARK: - 设置界面
//类似oc中的分类，分类中不能定义‘存储性’属性，可以定义readonly的属性，swift中同样如此
extension MainViewController {
    ///设置撰写按钮
    private func setupComposedButton() {
        tabBar.addSubview(composedButton)
        //2.调整按钮
        let count = children.count
        //-1让按钮宽一点，解决手指触摸容错
        let w = tabBar.bounds.width / CGFloat(count) - 1
        composedButton.frame = tabBar.bounds.insetBy(dx: 2 * w, dy: 0)
        //3添加监听方法
        composedButton.addTarget(self, action: #selector(clickComposedButton), for: .touchUpInside)
    }
    ///添加所有控制器
    private func addChildViewControllers() {
        
        addChildViewController(vc: HomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(vc: MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        addChild(UIViewController())
        addChildViewController(vc: DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(vc: ProfileTableViewController(), title: "我", imageName: "tabbar_profile")

    }
    private func addChildViewController(vc: UIViewController, title: String, imageName: String) {
        //设置标题---由内至外设置的
        vc.title = title
        //设置图像
        vc.tabBarItem.image = UIImage(named: imageName)
        //导航控制器
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}
