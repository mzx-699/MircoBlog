//
//  DiscoverTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

class DiscoverTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: "登陆后，最新、最热微博尽在掌握，不会再与实事潮流擦肩而过")
    }

}
