//
//  VisitorTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

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
    }
}
