//
//  ProfileTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

class ProfileTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView?.setupInfo(imageName: "visitordiscover_image_profile", title: "登陆后，你的微博、相册、个人资料会显示在这里")
    }

}
