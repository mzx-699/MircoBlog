//
//  WBrefreshControl.swift
//  MircoBlog
//
//  Created by apple on 2021/4/20.
//

import UIKit
///下拉刷新控件的偏移量
private let WBRefreshControlOffset:CGFloat = -50
///自定义刷新控件-负责处理刷新逻辑
class WBrefreshControl: UIView {
    private var isRefreshing: Bool = false
    //MARK: - 重新系统方法
    func endRefreshing() {
//        super.endRefreshing()
        //停止动画
        refreshView.stopAnimation()
    }
    ///主动触发开始刷新动画 -- 不不会触发监听方法
    func beginRefreshing() {
//        super.beginRefreshing()
        refreshView.startAnimation()
    }
    //MARK: - kvo监听方法
    //始终呆在屏幕上；下拉的时候，frame的y一直变小，相反（向上推）一直变大；默认y值是0
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if frame.origin.y > 0 {
//            return
//        }
//        //判断是否正在刷新
//        if isRefreshing {
//            refreshView.startAnimation()
//            return
//        }
//        if frame.origin.y < WBRefreshControlOffset && !refreshView.rotateFlag {
//            refreshView.rotateFlag = true
//        }
//        else if frame.origin.y >= WBRefreshControlOffset && refreshView.rotateFlag {
//            refreshView.rotateFlag = false
//        }
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
//    override init() {
//        super.init()
//        setupUI()
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        tintColor = UIColor.clear
        addSubview(refreshView)
        //从xib加载的控件，需要指定大小约束
        refreshView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(refreshView.bounds.size)
        }
        //使用kvo监听位置变化 --主队列，当主线程有任务，就不调度队伍中的任务执行
        //当前运行循环中所有代码执行完毕后，运行循坏结束前，开始监听
        //方法触发会在下一次运行循环开始，每一次有交互的动作后，才会有运行循环开始
//        DispatchQueue.main.async {
//            self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
//        }
        
    }
    deinit {
        //删除kvo
        self.removeObserver(self, forKeyPath: "frame")
    }
    //MARK: - 懒加载控件
    private lazy var refreshView = WBRefreshView.refreshView()

}
///刷新视图-负责处理动画显示
class WBRefreshView: UIView {
    ///箭头旋转标记
    var rotateFlag = false {
        didSet {
            rotateTipIcon()
            if rotateFlag == true {
                tipLabel.text = "释放刷新数据..."
            }
            else {
                tipLabel.text = "下拉开始刷新..."
            }
        }
    }
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var loadingIconView: UIImageView!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipIconView: UIImageView!
    ///从xib加载视图
    class func refreshView() -> WBRefreshView {
        //推荐使用nib的方式加载xib
        let nib = UINib(nibName: "WBRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! WBRefreshView
    }
    ///旋转图标转动
    private func rotateTipIcon() {
        var angle = Double.pi
        angle += rotateFlag ? -0.0000001 : 0.0000001
        //旋转动画，顺时针优先+就近原则，选择路最近的一条
        UIView.animate(withDuration: 0.5) {
            self.tipIconView.transform = self.tipIconView.transform.rotated(by: CGFloat(angle))
        }
    }
    ///播放加载动画
    func startAnimation() {
        tipView.isHidden = true
        //判断动画是否已经被添加
        let key = "transform.rotation"
        if loadingIconView.layer.animation(forKey: key) != nil {
            return
        }
        let anim = CABasicAnimation(keyPath: key)
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 0.5
        anim.isRemovedOnCompletion = false
        loadingIconView.layer.add(anim, forKey: key)
    }
    ///停止加载动画
    func stopAnimation() {
        tipView.isHidden = false
        loadingIconView.layer.removeAllAnimations()
    }
}
