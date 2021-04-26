//
//  PhotoBrowserCell.swift
//  MircoBlog
//
//  Created by apple on 2021/4/25.
//

import UIKit
import SDWebImage
import SVProgressHUD
protocol PhotoBrowserCellDelegate: NSObjectProtocol {
    func photoBrowerCellDidTapImage()
}
///照片查看cell
class PhotoBrowserCell: UICollectionViewCell {
    weak var photoDelegate: PhotoBrowserCellDelegate?
    //MARK: - 监听方法
    /**
     手势识别是对touch的一个封装，uiscrollview支持捏合手势，一般做过手势监听的控件，会屏蔽掉touch事件
     */
    @objc private func tapImage() {
        photoDelegate?.photoBrowerCellDidTapImage()
    }

    //MARK: - 图像地址
    var imageURL: URL? {
        didSet {
            guard let url = imageURL else {
                return
            }
            //恢复scrollview
            resetScrollView()
            //1.url缩略图地址
            //从磁盘加载缩略图图像
            let placeholderImage = SDImageCache.shared.imageFromDiskCache(forKey: url.absoluteString)
            setPlaceHolder(image: placeholderImage)
            placeHolder.setNeedsDisplay()
            //异步加载大图 sdwebImage 一旦设置了url，准备异步加载，会清除之前的图片，如果之前的图片也是异步下载但是没有完成，会取消之前的异步操作
            //如果url对应的图像已经被缓存，会直接从磁盘读取不会走网络加载
            //几乎所有的第三方框架，所有回调都是异步的；不是所有的程序都需要进度回调，进度回调的频率非常高，如果在主线程，会造成主线程卡顿
            imageView.sd_setImage(with: largeURL(url: url), placeholderImage: nil, options: [], context: nil) { (current, total, _) in
                //更新进度
                DispatchQueue.main.async {
                    self.placeHolder.progress = CGFloat(current) / CGFloat(total)
                }
            } completed: { (image, _, _, _) in
                //判断图像是否下载成功
                if image == nil {
                    SVProgressHUD.showInfo(withStatus: "您的网络不给力，图片下载失败")
                    return
                }
                //隐藏占位图像
                self.placeHolder.isHidden = true
                //设置视图位置和大小
                self.setPosition(image: image!)
            }
        }
    }
    
    /// 设置占位图像的内容
    /// - Parameter image: 本地缓存的缩略图，如果缩略图下载失败，就为空
    private func setPlaceHolder(image: UIImage?) {
        placeHolder.isHidden = false
        placeHolder.image = image
        placeHolder.sizeToFit()
        placeHolder.center = scrollView.center
        
    }
    
    /// 重设scrollview内容属性
    private func resetScrollView() {
        //重设imageview scrollview在处理缩放的时候，是调整代理方法返回视图的transform来实现的
        imageView.transform = .identity
        //重设scrollview
        scrollView.contentInset = .zero //缩放之后的居中
        scrollView.contentOffset = .zero //决定scrollview的偏移位置
        scrollView.contentSize = .zero // 滚动范围
    }
    /// 设置imageView的位置 长短图处理
    /// - Parameter image: image
    private func setPosition(image: UIImage) {
        let size = self.displaySize(image: image)
        //判断图片高度
        if size.height < scrollView.bounds.height {
            //上下居中显示，调整frame x/y 一旦缩放，影响滚动范围
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let y = (scrollView.bounds.height - size.height) * 0.5
            //内容边距 调整控件位置，不影响控件滚动
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
        }
        else {
            //自动设置大小
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            scrollView.contentSize = size
        }

    }
    
    /// 根据scrollview的宽度计算等比例缩放之后的图片尺寸
    /// - Parameter image: image
    /// - Returns: 缩放之后的size
    private func displaySize(image: UIImage) -> CGSize {
        let w = scrollView.bounds.width
        let h = image.size.height * w / image.size.width
        return CGSize(width: w, height: h)
    }
    
    /// 返回中等尺寸的URL
    /// - Parameter url: 缩略图url
    /// - Returns: 中等尺寸的url
    private func largeURL(url: URL) -> URL {
        
        //转换成String
        var urlString = url.absoluteString
        //替换单词
        urlString = urlString.replacingOccurrences(of: "/thumbnail/", with: "/large/")
//        print(urlString)
        return URL(string: urlString)!
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(placeHolder)
        //设置位置
        var rect = bounds
        rect.size.width -= 20
        scrollView.frame = rect
        //设置scrollview的缩放
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        
        //添加手势识别
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        //imageviwe默认不支持用户交互
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
    }
    //MARK: - 懒加载控件
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var imageView: UIImageView = UIImageView()
    ///占位图像
    private lazy var placeHolder: ProgressImageView = ProgressImageView()
}

//MARK: - UIScrollViewDelegate
extension PhotoBrowserCell: UIScrollViewDelegate {
    //返回被缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// 缩放完成后执行
    /// - Parameters:
    ///   - scrollView: scrollView
    ///   - view: 被缩放的视图
    ///   - scale: 被缩放的比例
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //bouns是固定的
        var offsetY = (scrollView.bounds.height - view!.frame.height) * 0.5
        offsetY = offsetY < 0 ? 0 : offsetY
        var offsetX = (scrollView.bounds.width - view!.frame.width) * 0.5
        offsetX = offsetX < 0 ? 0 : offsetX
        //设置间距
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    ///缩放时调用
    /**
        ad决定缩放比例
        adcd共同决定旋转
        tx ty设置位移
        定义控件位置 frame = center + bounds * transform
     */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
}
