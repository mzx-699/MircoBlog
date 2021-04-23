//
//  EmoticonView.swift
//  微博-表情键盘
//
//  Created by apple on 2021/4/21.
//

import UIKit
private let EmoticonViewCellId = "EmoticonViewCellId"
//MARK: - 表情键盘视图
class EmoticonView: UIView {

    ///传递表情回调
    private var selectedEmoticonCallBack: (_ emoticon: Emoticon) -> ()
    //MARK: - 监听方法
    @objc private func clickItem(item: UIBarButtonItem) {
        //item 第几组的第几个
        let indexPath = IndexPath(item: 0, section: item.tag)
        //滚动collectionView
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    //MARK: - 构造函数
    //自定义构造函数
    init(selectedEmotion : @escaping (_ emoticon: Emoticon) -> ()) {
        //记录闭包属性
        selectedEmoticonCallBack = selectedEmotion
        //调用父类的构造函数
        var rect = UIScreen.main.bounds
        rect.size.height = 226
        super.init(frame: rect)
        backgroundColor = UIColor.red
        setupUI()
        //滚动到第一页
        let indenPath = IndexPath(item: 0, section: 1)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indenPath, at: .left, animated: false)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - 懒加载控件
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: EmoticonLayout())
    //调用系统提供的类，可以不指定类型
    private lazy var toolbar = UIToolbar()
    ///表情包数组
    private lazy var packages = EmoticonManager.sharedManager.packages
    
    //MARK: - 表情布局（类中类，只允许被包含的类使用）
    private class EmoticonLayout: UICollectionViewFlowLayout {
        //第一次布局的时候会被自动调用
        //尺寸已经被设置好216 toolbar 36
        override func prepare() {
            super.prepare()
            
            let col: CGFloat = 7
            let row: CGFloat = 3
            let w: CGFloat = collectionView!.bounds.width / col
            let margin = (collectionView!.bounds.height - row * w) * 0.499
            itemSize = CGSize(width: w, height: w)
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            //上面和下面加一个margin
            sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }
    
}
//MARK: - 设置界面
//用private 修饰extension 内部的方法都是私有的
private extension EmoticonView {
    
    func setupUI() {
        //设置toolbar颜色
        toolbar.tintColor = UIColor.darkGray
        
        addSubview(toolbar)
        addSubview(collectionView)
        toolbar.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(44)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(toolbar.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        //准备控件
        prepareToolbar()
        prepareCollectionView()
    }
    
    func prepareToolbar() {
        //设置按钮内容
        var items = [UIBarButtonItem]()
        //toolbar中，通常是一组功能相近的操作，只是操作的类型不同，通常利用tag区分
        var index = -1
        for p in packages {
            items.append(UIBarButtonItem(title: p.group_name_cn, style: .plain, target: self, action: #selector(clickItem(item:))))
            index += 1
            items.last?.tag = index
            //添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        //设置items
        toolbar.items = items
    }
    func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.lightGray
        //注册cell
        collectionView.register(EmoticonViewCell.self, forCellWithReuseIdentifier: EmoticonViewCellId)
        
        //数据源
        collectionView.dataSource = self
        //代理
        collectionView.delegate = self
    }
}
//MARK: - 数据源、代理方法
extension EmoticonView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //获取表情模型
        let em = packages[indexPath.section].emoticons[indexPath.item]
        //传递表情
        //执行回调
        selectedEmoticonCallBack(em)
    }
    //返回分组数量 表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    //返回每个表情包的表情数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonViewCellId, for: indexPath) as! EmoticonViewCell
        cell.emoticon = packages[indexPath.section].emoticons[indexPath.item]
        return cell
    }
}
//MARK: - 表情视图cell
class EmoticonViewCell: UICollectionViewCell {
    ///表情模型
    var emoticon: Emoticon? {
        didSet {
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), for: .normal)
            //设置emoji 不要加上判断否则会显示不正常，因为需要重复设置保证没有code的是空的
            emoticonButton.setTitle(emoticon?.emoji, for: .normal)
            //设置删除按钮
            if emoticon!.isRemoved {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
            }
        }
    }
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emoticonButton)
        emoticonButton.backgroundColor = UIColor.white
        //上下左右缩4
        emoticonButton.frame = bounds.insetBy(dx: 4, dy: 4)
        //字体的大小和高度想尽
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        //取消按钮交互
        emoticonButton.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载控件
    lazy var emoticonButton: UIButton = UIButton()
    
}
