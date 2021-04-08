//
//  VisitorTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit
//基础vc继承访客vc，用userLogon判断是否登陆，为false设置访客视图
//访问访客视图，子类调用父类加载，
class VisitorTableViewController: UITableViewController {
    /**
     提问
     1.应用程序中，有几个visitorView 每个控制器有各自不同的访客视图
     2.访客视图 如果用懒加载，访客视图始终都会被创建出来
     */
    private var userLogon = false
    //访客视图
    var visitorView: VisitorView?
    override func loadView() {
//        print("come here")
//        super.loadView()
        //根据用户登录情况，决定显示的根视图
        userLogon ? super.loadView() : setupVisitorView()
    }
    
    ///设置访客视图
    private func setupVisitorView() {
        
        //替换根视图
        visitorView = VisitorView()
        
        view = visitorView
        
        //添加监听方法
        visitorView?.loginButton.addTarget(self, action: #selector(visitorViewDidLogin), for: .touchUpInside)
        visitorView?.registerButton.addTarget(self, action: #selector(visitorViewDidRegister), for: .touchUpInside)
        
        
        //设置导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(visitorViewDidRegister))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登陆", style: .plain, target: self, action: #selector(visitorViewDidLogin))
    }
}

///访客视图监听方法
extension VisitorTableViewController {
    @objc func visitorViewDidRegister() {
        print("visitorViewDidRegister")
    }
    @objc func visitorViewDidLogin() {
        let vc = OAtuhViewController()
        let nav = UINavigationController(rootViewController: vc)
        //跳转风格
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}
