//
//  StatusPictureView.swift
//  MircoBlog
//
//  Created by apple on 2021/4/16.
//

import UIKit
import SDWebImage
private let StatusPictureViewItemMargin: CGFloat = 8
///可重用标示符
private let StatusPictureCellId = "StatusPictureCellId"
///配图视图
class StatusPictureView: UICollectionView {
    
    ///微博视图模型
    var viewModel: StatusViewModel? {
        didSet {
            //修改当前视图的大小
            sizeToFit()
            //刷新数据 如果不刷新，后续的collectionView一旦被复用，就不调用数据源方法
            reloadData()
        }
    }
    //sizetofit调用下面的函数
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calcViewSize()
    }
    //MARK: - 构造函数
    init() {
        let layout = UICollectionViewFlowLayout()
        //设置间距 默认itemSize 50*50
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        backgroundColor = UIColor.white
        
        //设置数据源 自己当自己的数据源，自定义视图的小框架
        dataSource = self
        //注册可重用cell
        register(StatusPicutreCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
//MARK: - collectionView数据源方法
extension StatusPictureView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbnailUrls?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusPictureCellId, for: indexPath) as! StatusPicutreCell
        cell.imageUrl = viewModel?.thumbnailUrls![indexPath.item]
        return cell
    }
}
//MARK: - 计算视图大小
extension StatusPictureView {
    private func calcViewSize() -> CGSize {
        //每行照片数量
        let rowCount: CGFloat = 3
        //最大宽度
        let maxWidth = UIScreen.main.bounds.width - 2 * StatusCellMargin
        let itemWidth = (maxWidth - 2 * StatusPictureViewItemMargin) / rowCount
        
        //设置layout的itemSize
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        //获取图片数量
        let count = viewModel?.thumbnailUrls?.count ?? 0
        
        //没有图片
        if count == 0 {
            return CGSize(width: 0, height: 0)
        }
        //一张图片
        if count == 1 {
            // TODO: - 临时指定大小
            let size = CGSize(width: 150, height: 120)
            //内部图片的大小
            layout.itemSize  = size
            //配图视图的大小
            return size
        }
        //四张图片返回2*2的大小
        if count == 4 {
            let w = 2 * itemWidth + StatusPictureViewItemMargin
            return CGSize(width: w, height: w)
        }
        //其他数量图片 按照九宫格
        //计算行数
        let row = CGFloat((count - 1) / Int(rowCount) + 1)
        let h = row * itemWidth + (row - 1) * StatusPictureViewItemMargin
        let w = CGFloat(count) * itemWidth + (rowCount - 1) * StatusPictureViewItemMargin
        
        return CGSize(width: w, height: h)
    }
}

//MARK: - 自定义配图cell
private class StatusPicutreCell: UICollectionViewCell {
    var imageUrl: URL? {
        didSet {
            iconView.sd_setImage(with: imageUrl, placeholderImage: nil, //调用oc框架时，可选项不严格
                                 options: [SDWebImageOptions.retryFailed, //超时不计入黑名单
                                                                                  SDWebImageOptions.refreshCached], //url不变，图像变，更新图像
                                 context:nil)
        }
    }
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载控件
    private lazy var iconView: UIImageView = UIImageView()
    
    private func setupUI() {
        contentView.addSubview(iconView)
        //因为cell会变化，另外不同的cell大小不一样
        iconView.snp.makeConstraints { (make) in
            //上左下右
            make.edges.equalTo(contentView.snp.edges)
        }
    }
}
