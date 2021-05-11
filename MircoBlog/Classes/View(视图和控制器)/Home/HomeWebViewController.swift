//
//  HomeWebViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/5/11.
//

import UIKit
import WebKit
class HomeWebViewController: UIViewController {
    
    private lazy var webView = WKWebView()
    var url: URL
    
    //MARK: - 构造函数
    init(url: URL) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = webView
        title = "网页"
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
    }
    


}
