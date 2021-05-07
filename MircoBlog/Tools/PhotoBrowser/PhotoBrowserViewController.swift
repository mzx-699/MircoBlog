//
//  PhotoBrowserViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/25.
//

import UIKit
import SVProgressHUD
///可重用标示符
private let PhotoBrowserViewCellId = "PhotoBrowserViewCellId"
class PhotoBrowserViewController: UIViewController {

    ///照片url数组
    private var urls: [URL]
    ///当前选中的照片索引
    private var currentIndexPath: IndexPath
    //MARK: - 监听方法
    ///关闭
    @objc private func close() {
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    ///保存照片
    @objc private func save() {
        //拿到图片
        let cell = collectionView.visibleCells[0] as! PhotoBrowserCell
        //可能因为网络问题没有图片，需要提示
        guard let image = cell.imageView.image else {
            return
        }
        //保存图片
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject?) {
        let message = error == nil ? "保存成功" : "保存失败"
        SVProgressHUD.showInfo(withStatus: message)
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
    //loadview 和xib&sb等价 主要职责创建视图层次结构，loadview函数执行完毕，view上的元素全部创建完成
    //如果view == nil，系统会在调用view的getter方法时，自动调用loadview，创建view
    override func loadView() {
        //不需要调用super的loadView loadView的作用就是自定义view，调用super的会消耗性能
        //1.设置根视图
        var rect = UIScreen.main.bounds
        rect.size.width += 20
        view = UIView(frame: rect)
        
        setupUI()
    }
    //是视图加载完成被调用，loadview执行完毕被执行
    //主要做数据加载或者其他处理
    //目前很多程序，建立子控件都写在viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
//        print(urls)
//        print(currentIndexPath)
    }
    
    
    //MARK: - 懒加载控件
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: PhotoBrowserViewLayout())
    ///关闭
    private lazy var closeButton: UIButton = UIButton(title: "关闭", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)
    ///保存
    private lazy var saveButton: UIButton = UIButton(title: "保存", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)
    //MARK: - 自定义流水布局
    private class PhotoBrowserViewLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            
            itemSize = collectionView!.bounds.size
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }

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
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(closeButton.snp.size)
        }
        //监听方法
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        prepareCollectionView()
    }
    ///准备collectionView
    private func prepareCollectionView() {
        //注册可重用cell
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: PhotoBrowserViewCellId)
        //设置数据源
        collectionView.dataSource = self
    }
}

//MARK: - UICollectionViewDataSource
extension PhotoBrowserViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserViewCellId, for: indexPath) as! PhotoBrowserCell
        cell.imageURL = urls[indexPath.item]
        cell.photoDelegate = self
        return cell
    }
}

//MARK: - PhotoBrowserCellDelegate
extension PhotoBrowserViewController: PhotoBrowserCellDelegate {
    func photoBrowerCellShouldDidDismiss() {
        close()
    }
    func photoBrowserCellDidZoom(scale: CGFloat) {
        let isHidden = (scale < 1)
        hideControls(isHidden: isHidden)
        if isHidden {
            //1.根据scale 修改根视图透明度
            view.alpha = scale
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        else {
            view.alpha = 1.0
            //还原
            view.transform = .identity
        }
    }
    ///隐藏或者显示控件
    private func hideControls(isHidden: Bool) {
        closeButton.isHidden = isHidden
        saveButton.isHidden = isHidden
        collectionView.backgroundColor = isHidden ? UIColor.clear : UIColor.black
    }
}
//MARK: - PhotoBrowserDismissDelegate
extension PhotoBrowserViewController: PhotoBrowserDismissDelegate {
    
    func imageViewForDismiss() -> UIImageView {
        let iv = UIImageView()
        
        //设置内容填充模式
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        //设置图像 直接从当前显示的cell中获取
        let cell = collectionView.visibleCells[0] as! PhotoBrowserCell
        iv.image = cell.imageView.image
        
        //设置位置 坐标转换 由父视图进行转换
        iv.frame = cell.scrollView.convert(cell.imageView.frame, to: UIApplication.shared.windows.first{$0.isKeyWindow})
        return iv
    }
    func indexPathForDismiss() -> IndexPath {
        return collectionView.indexPathsForVisibleItems[0]
    }
}
