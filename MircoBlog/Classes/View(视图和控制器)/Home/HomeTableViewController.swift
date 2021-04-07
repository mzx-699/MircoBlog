//
//  HomeTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

class HomeTableViewController: VisitorTableViewController {
    //调用访客视图didload
    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView?.setupInfo(imageName: nil, title: "关注一些人，回这里看看有什么惊喜")
    }



}
