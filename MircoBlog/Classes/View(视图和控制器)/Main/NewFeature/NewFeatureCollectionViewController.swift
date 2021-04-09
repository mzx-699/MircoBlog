//
//  NewFeatureCollectionViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/9.
//

import UIKit
import SnapKit
///可重用cellID
private let WBNewFeatureCollectionViewCellId = "WBNewFeatureCollectionViewCellId"
///新特性图像书香
private let WBNewFeatureImageCount = 4

class NewFeatureCollectionViewController: UICollectionViewController {
    //懒加载属性必须要崽控制器实例化之后才会被创建
    
    //MARK: - 构造函数
    init() {
        //super指定的构造函数
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UIScreen.main.bounds.size
        //中间距离
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0
        //滚动方向
        layout.scrollDirection = .horizontal
        //构造函数完成之后，内部属性才会被创建
        super.init(collectionViewLayout: layout)
        
        //分页
        collectionView.isPagingEnabled = true
        //弹簧效果
        collectionView.bounces = false
        //水平指示器
        collectionView.showsHorizontalScrollIndicator = false
        //解决按钮点击不显示高亮图片
        collectionView.delaysContentTouches = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //默认是no
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //注册可重用cell
        self.collectionView!.register(NewFeatureCell.self, forCellWithReuseIdentifier: WBNewFeatureCollectionViewCellId)

    }


    //MARK: - UICollectionViewDataSource
    //每个分组中格子的数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WBNewFeatureImageCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WBNewFeatureCollectionViewCellId, for: indexPath) as! NewFeatureCell
        cell.imageIndex = indexPath.item
        return cell
    }
    //停止滚动方法
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //最后一页调用动画方法
        //根据contentoffset计算页数
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        //判断是否是最后一页
        if page != WBNewFeatureImageCount - 1 {
            return
        }
        //cell播放动画
        let cell = collectionView.cellForItem(at: IndexPath(item: page, section: 0)) as! NewFeatureCell
        cell.showButtonAnim()
    }
}

//MARK: - 新特性cell
private class NewFeatureCell: UICollectionViewCell {
    
    //图像索引
    var imageIndex: Int = 0 {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            //隐藏按钮
            startButton.isHidden = true
        }
    }
    
    ///点击开始体验
    @objc private func clickStartButton() {
        print("开始体验")
        }
    
    ///显示按钮动画
    func showButtonAnim() {
        startButton.isHidden = false
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        //关闭用户交互
        //不能进行用户交互的情况 透明度<0.01 hidden = true 本身位置在外边 在上面盖了一个
        startButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1.6, //动画时长
                       delay: 0, //延长时间
                       usingSpringWithDamping: 0.6, //弹力系数，越小越弹
                       initialSpringVelocity: 10, // 初始速度，模拟重力加速度
                       options: []) { //动画选项
            self.startButton.transform = CGAffineTransform.identity
        } completion: { (bool) in
            self.startButton.isUserInteractionEnabled = true
        }

    }
    
    //frame的大小是layout.itemSize指定的
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //添加控件
        addSubview(iconView)
        addSubview(startButton)
        //指定位置
        iconView.frame = bounds
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).multipliedBy(0.7)
        }
        //3.监听方法
        startButton.addTarget(self, action: #selector(clickStartButton), for: .touchUpInside)
    }
    //MARK: - 懒加载控件
    //图像
    private lazy var iconView: UIImageView = UIImageView()
    //启动按钮
    private lazy var startButton: UIButton = UIButton(title: "开始体验", color: UIColor.white, imageName: "new_feature_finish_button")
}
