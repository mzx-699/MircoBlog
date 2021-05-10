//
//  StatusPictureView.swift
//  MircoBlog
//
//  Created by apple on 2021/4/16.
//

import UIKit
import SDWebImage
import UICollectionViewLeftAlignedLayout
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
        let layout = UICollectionViewLeftAlignedLayout()
        //设置间距 默认itemSize 50*50
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        backgroundColor = UIColor.white
        //设置数据源 自己当自己的数据源，自定义视图的小框架
        dataSource = self
        //设置代理
        delegate = self
        //注册可重用cell
        register(StatusPicutreCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}
//MARK: - collectionView UICollectionViewDelegate数据源方法
extension StatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    ///选中照片
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //动画转场协议
        //测试
//        photoBrowserPresentFromRect(indexPath: indexPath)
//        photoBrowserPresentToRect(indexPath: indexPath)

//        print("点击照片\(indexPath)\(viewModel?.thumbnailUrls)")
        //传递数据 当前url的数组/当前用户选中的索引
        //通知组成 名字（通知中心监听）/object（发送通知同时传递的对象，单值）/userInfo（传递多值的时候，使用的数据字典） -> Key
        NotificationCenter.default.post(name: NSNotification.Name(WBStatusSelectedPhotoNotification), object: self, userInfo: [WBStatusSelectedPhotoIndexPathKey : indexPath, WBStatusSelectedPhotoURLsKey : viewModel!.thumbnailUrls!])
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbnailUrls?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusPictureCellId, for: indexPath) as! StatusPicutreCell
        cell.imageUrl = viewModel?.thumbnailUrls![indexPath.item]
        cell.backgroundColor = UIColor.clear
//        cell.backgroundColor = UIColor.red
        return cell
    }
}

//MARK: - PhotoBrowserPresentDelegate
extension StatusPictureView: PhotoBrowserPresentDelegate {
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect {
        //根据indexPath获取用户选择的cell
        let cell = cellForItem(at: indexPath)!
        //通过cell知道cell对应在屏幕上的准确位置
        //在不同的视图之间坐标系的转换 由self的父视图进行转换
        //由collectionview将cell的frame位置转换成keywindow对应的frame位置
        let rect = convert(cell.frame, to: UIApplication.shared.windows.first{$0.isKeyWindow})
        //测试
//        let iv = imageViewForPresent(indexPath: indexPath)
//        iv.frame = rect
//        UIApplication.shared.windows.first{$0.isKeyWindow}?.addSubview(iv)
        return rect
    }
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect {
        //根据缩略图大小，等比例计算位置
        guard let key = viewModel?.thumbnailUrls?[indexPath.item].absoluteString else {
            return .zero
        }
        //从本地直接获取缓存图片
        guard let image = SDImageCache.shared.imageFromDiskCache(forKey: key) else {
            return .zero
        }
        //根据图像大小计算全屏大小
        let w = UIScreen.main.bounds.width
        let h = image.size.height * w / image.size.width
        //对高度进行额外处理
        let screenHeight = UIScreen.main.bounds.height
        var y:CGFloat = 0
        //图片短 需要垂直居中
        if h < screenHeight {
            y = (screenHeight - h) * 0.5
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
    }
    //创建imageview参与动画，代替原来位置的缩略图，来作为最初的图像
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView {
        let iv = UIImageView()
        //设置内容填充模式
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        //设置图像（缩略图） 如果已经存在本地缓存，不会发起网络请求
        if let url = viewModel?.thumbnailUrls?[indexPath.item] {
            iv.setImageWith(url)
        }
        return iv
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
            var size = CGSize(width: 150, height: 120)
            //利用sdwebimage检查本地缓存图像
            ///key url完整字符串
            //问：sdwebImage是如何设置缓存文件的文件名的 对完成url字符串的‘MD5’
            if let key = viewModel?.thumbnailUrls?.first?.absoluteString {
                if let image = SDImageCache.shared.imageFromCache(forKey: key, options: [.preloadAllFrames, .queryMemoryData], context: nil) {
                    size = image.size

                }
            }
            //过窄处理 针对长图 --- 改变条件进行测试
            size.width = size.width < 40 ? 40 : size.width
            //过宽处理
            if size.width > 300 {
                let w: CGFloat = 300
                let h = size.height / size.width * w
                size = CGSize(width: w, height: h)
            }
            //内部图片的大小
            layout.itemSize  = size
            //配图视图的大小
            return size
        }
        //四张图片返回2*2的大小
        //宽度+1，让图片能放下
        if count == 4 {
            let w = 2 * itemWidth + StatusPictureViewItemMargin + 1
            return CGSize(width: w, height: w)
        }
        //其他数量图片 按照九宫格
        //计算行数
        let row = CGFloat((count - 1) / Int(rowCount) + 1)
        let h = row * itemWidth + (row - 1) * StatusPictureViewItemMargin
        let w = rowCount * itemWidth + (rowCount - 1) * StatusPictureViewItemMargin + 1
        
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
            let pathExtension = (imageUrl!.absoluteString as NSString).pathExtension.lowercased()
            gifIconView.isHidden = (pathExtension != "gif") //不等于隐藏
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
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        //设置填充模式
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.clear
        //需要裁切图片
        iv.clipsToBounds = true
        return iv
    }()
    private lazy var gifIconView: UIImageView = UIImageView(imageName: "timeline_image_gif")
    
    private func setupUI() {
        contentView.addSubview(iconView)
        iconView.addSubview(gifIconView)
        //因为cell会变化，另外不同的cell大小不一样
        iconView.snp.makeConstraints { (make) in
            //上左下右
            make.edges.equalTo(contentView.snp.edges)
        }
        gifIconView.snp.makeConstraints { (make) in
            //右下角
            make.right.equalTo(iconView.snp.right)
            make.bottom.equalTo(iconView.snp.bottom)
        }
    }
}

