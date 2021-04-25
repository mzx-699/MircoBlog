//
//  PhotoBrowserViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/25.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    ///照片url数组
    private var urls: [URL]
    ///当前选中的照片索引
    private var currentIndexPath: IndexPath
    //MARK: - 监听方法
    ///关闭
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    ///保存照片
    @objc private func save() {
        print("save")
    }
    //MARK: - init 属性都是必选，后续不用考虑解包
    init(urls: [URL], indexPath: IndexPath) {
        self.urls = urls
        self.currentIndexPath = indexPath
        //调用父类方法
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) hasnot been implemented")
    }
    //MARK: - 视图周期
    override func loadView() {
        //不需要调用super的loadView loadView的作用就是自定义view，调用super的会消耗性能
        //1.设置根视图
        let rect = UIScreen.main.bounds
        view = UIView(frame: rect)
        
        setupUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print(urls)
        print(currentIndexPath)
    }
    
    
    //MARK: - 懒加载控件
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    ///关闭
    private lazy var closeButton: UIButton = UIButton(title: "关闭", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)
    ///保存
    private lazy var saveButton: UIButton = UIButton(title: "保存", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)

}
//MARK: - 设置UI
extension PhotoBrowserViewController {
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        collectionView.frame = view.bounds
        closeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(8)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(closeButton.snp.bottom)
            make.right.equalTo(view.snp.right).offset(-8)
            make.size.equalTo(closeButton.snp.size)
        }
        //监听方法
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
}
