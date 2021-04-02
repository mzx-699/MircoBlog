//
//  MessageTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit

class MessageTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: "登陆后，别人评论你的微博，发给你的消息，都会在这里收到通知")
    }


}
