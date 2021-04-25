//
//  ComposeViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/22.
//

import UIKit
import SVProgressHUD
//MARK: - 撰写控制器
class ComposeViewController: UIViewController {
    private lazy var picturePickerController = PicturePickerCollectionViewController()
    ///表情视图键盘
    private lazy var emoticonView: EmoticonView = EmoticonView { [weak self] (emoticon) in
        self?.textView.insertEmotion(em: emoticon)
    }
    //MARK: - 监听方法
    ///关闭
    @objc private func close() {
        //关闭键盘
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    ///发布微博
    @objc private func sendStatus() {
//        print("发送微博")
        //1.获得文本内容
        let text = textView.emoitconText
        //2.发布微博
        //照片
        let image = picturePickerController.pictures.last
        NetworkTools.sharedTools.sendStatus(status: text, image: image) { (result, error) in
            if error != nil {
//                print("发布微博出错了")
                print(error!)
//                print(image)
                SVProgressHUD.showInfo(withStatus: "发布微博出错了")
                return
            }
            print(result!)
            self.close()
        }
    }
    ///选择表情
    @objc private func selectEmoticon() {
//        print("选择表情")
        //退掉系统键盘
        textView.resignFirstResponder()
        //设置键盘
        textView.inputView = textView.inputView == nil ? emoticonView : nil
        //重新激活键盘
        textView.becomeFirstResponder()
    }
    ///选择照片
    @objc private func selectPicture() {
        //退掉键盘
        textView.resignFirstResponder()
        //如果已经更新约束，就不再执行代码
        if picturePickerController.view.frame.height > 0 {
            return
        }
//        print("selectPicture")
        //1.修改照片选择控制器视图的约束
        picturePickerController.view.snp.updateConstraints { (make) in
            make.height.equalTo(view.bounds.height * 0.6)
        }
        //2.修改文本视图的约束
        //重建约束，会将之前的约束全部都删除，重建建立
        textView.snp.remakeConstraints { (make) in
            make.top.equalTo(view.snp_topMargin)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(picturePickerController.view.snp.top)
        }
        //动画更新约束
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    //MARK: - 处理键盘
    @objc private func keyboardChanged(n: Notification) {
//        print(n)
        //1.获取目标的rect
        let rect = (n.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).cgRectValue
        //获取目标的动画时长 --- 字典中的数值是NSNumber
        let duration = (n.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! NSNumber).doubleValue
        //更新toolbar约束
        //键盘没弹出时，是0，弹出时，是键盘的高度
        let offset = rect.origin.y - UIScreen.main.bounds.height
        //动画曲线数值
        //曲线值=7 如果之前的动画没有完成，启动了其他动画，让动画的图层，直接运动到后续的目标位置，一旦设置了7，动画时长无效，动画时长统一变成0.5s
        let curve = (n.userInfo!["UIKeyboardAnimationCurveUserInfoKey"] as! NSNumber).intValue
        
        toolBar.snp.updateConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(offset)
        }


        // TODO: - 动画bug
        let _ = UIViewPropertyAnimator(duration: duration, curve: UIView.AnimationCurve(rawValue: curve)!) {
            self.view.layoutIfNeeded()
        }
        
//        let anim = toolBar.layer.animation(forKey: "position")
//        anim?.duration = 11111
//        print(anim?.duration)

        
//        UIView.animate(withDuration: duration, delay: 0, options: []) {
//            self.view.layoutIfNeeded()
//
//        } completion: { (_) in
//
//        }
        
        
//        print(rect)
    }
    //MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(n:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        textView.delegate = self
    }
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = UIView()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //激活键盘 如果已经存在照片控制器视图，就不再激活键盘
        if picturePickerController.view.frame.height == 0 {
            textView.becomeFirstResponder()
        }
        
    }
    //MARK: - 懒加载控件
    ///工具条
    private lazy var toolBar = UIToolbar()
    ///文本视图
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textColor = UIColor.darkGray
        //始终允许垂直滚动
        tv.alwaysBounceVertical = true
        //拖拽关闭键盘
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    ///占位标签
    private lazy var placeHolderLabel: UILabel = UILabel(title: "分享新鲜事...", fontSize: 18, color: UIColor.lightGray)
    
}
//MARK: - UITextViewDelegate
extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
        placeHolderLabel.isHidden = textView.hasText
    }
}
//MARK: - 设置界面
private extension ComposeViewController {
    
    func setupUI() {
        //解决导航栏和滚动视图共同显示的时候
        //取消自动调整滚动视图的间距 automaticallyAdjustsScrollViewInsets

        view.backgroundColor = UIColor.white
        prepareToolbar()
        prepareNavigationBar()
        prepareTextView()
        preparePicturePicker()
        //输入助理视图 --- 演示
//        textView.inputAccessoryView = toolBar
    }
    ///准备图片选择器
    private func preparePicturePicker() {
        //如果要调用其他控制器的内容，要进行add
        addChild(picturePickerController)
        //1.添加视图
//        view.addSubview(picturePickerController.view)
        view.insertSubview(picturePickerController.view, belowSubview: toolBar)
        picturePickerController.view.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(0)
        }
    }
    ///准备文本视图
    func prepareTextView() {
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp_topMargin)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(toolBar.snp.top)
        }
        
        //添加占位标签
        textView.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.top).offset(8)
            make.left.equalTo(textView.snp.left).offset(5)
        }
    }

    ///准备工具条
    func prepareToolbar() {
        //添加控件
        view.addSubview(toolBar)
        //设置背景颜色
        toolBar.backgroundColor = UIColor(white: 0.5, alpha: 1)
        toolBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(44)
        }
        let itemSettings = [["imageName": "compose_toolbar_picture", "actionName": "selectPicture"],
            ["imageName": "compose_mentionbutton_background"],
            ["imageName": "compose_trendbutton_background"],
            ["imageName": "compose_emoticonbutton_background", "actionName": "selectEmoticon"],
            ["imageName": "compose_addbutton_background"]]
        var items = [UIBarButtonItem]()
        for dict in itemSettings {
            items.append(UIBarButtonItem(imageName: dict["imageName"]!, tartget: self, actionName: dict["actionName"]))
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        //一旦赋值，相当于做了一次拷贝
        toolBar.items = items
    }
    ///准备导航栏
    func prepareNavigationBar() {
        //左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(sendStatus))
        //禁用发布微博按钮
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        //标题视图
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
        //添加子控件
        let titleLabel = UILabel(title: "发微博", fontSize: 15)
        let nameLabel = UILabel(title: UserAccountViewModel.sharedUserAccount.account?.screen_name ?? "",
                                fontSize: 13,
                                color: UIColor.lightGray)
        //MARK: - bug 上下颠倒
        titleView.addSubview(nameLabel)
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleView.snp.centerX)
            make.top.equalTo(titleView.snp.top).offset(3)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleView.snp.centerX)
            make.top.equalTo(titleLabel.snp.bottom).offset(titleView.bounds.height - titleLabel.bounds.height - nameLabel.bounds.height)
            
        }
        navigationItem.titleView = titleView
    }
}
