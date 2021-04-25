//
//  PicturePickerCollectionViewController.swift
//  微博-照片选择
//
//  Created by apple on 2021/4/23.
//

import UIKit
///可重用cellId
private let PicturePickerCellId = "PicturePickerCellId"
///最大选择照片索引
private let PicturePickMaxCount = 9
///照片选择控制器
class PicturePickerCollectionViewController: UICollectionViewController {
    ///配图数组
    private lazy var pictures = [UIImage]()
    ///当前用户选中的照片索引
    private var selectedIndex = 0
    init() {
        super.init(collectionViewLayout: PicturePickerLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //在collectionviewController中collectionview != view
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        //注册可重用cell
        self.collectionView.register(PicturePickerCell.self, forCellWithReuseIdentifier: "PicturePickerCellId")
    
    }
    
    //MARK: - 照片选择器布局
    private class PicturePickerLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            let count: CGFloat = 4
            let margin = UIScreen.main.scale * 4
            let w = (collectionView!.bounds.width - (count + 1) * margin) / count
            itemSize = CGSize(width: w, height: w)
            sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: 0, right: margin)
            minimumLineSpacing = margin
            minimumInteritemSpacing = margin
        }
    }
    

}

//MARK: - 数据源方法
extension PicturePickerCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //保证末尾有一个加号按钮，如果达到上限就不显示加号按键
        return pictures.count + (pictures.count == PicturePickMaxCount ? 0 : 1)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicturePickerCellId, for: indexPath) as! PicturePickerCell
        cell.picturePickerDelegate = self
//        cell.backgroundColor = UIColor.red
        //设置图像
        //如果下标大于等于数组数量 则数组越界
        cell.image = (indexPath.item < pictures.count) ? pictures[indexPath.item] : nil
        return cell
    }
}
//MARK: - 代理方法
extension PicturePickerCollectionViewController: PicturePickerCellDelegate {
    func picturePickerCellDidAdd(cell: PicturePickerCell) {
        //判断是否允许访问相册
        /**
         photoLibrary 保存的照片（可以删除） + 同步的照片（不允许删除）
         savedPhotosAlbum 保存的照片/屏幕截图/拍照
         */
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("无法访问照片库")
            return
        }
        //记录当前用户选中的照片索引
        selectedIndex = collectionView.indexPath(for: cell)!.item
        
        let picker = UIImagePickerController()
        //设置代理
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        //允许编辑
//        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
//        print("添加照片")
    }
    func picturePickerCellDidRemove(cell: PicturePickerCell) {
        //获取照片索引
        let indexPath = collectionView.indexPath(for: cell)!
        //删除数组
        //判断索引是否超出上限
        if indexPath.item >= pictures.count {
            return
        }
        //删除数据
        pictures.remove(at: indexPath.item)
        //动画刷新视图
        collectionView.deleteItems(at: [indexPath])
//        collectionView.reloadData()
//        print("删除照片")
    }
}
//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension PicturePickerCollectionViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 照片完成选择
    /// - Parameters:
    ///   - picker: 照片选择控制器
    ///   - info: info字典
    ///一旦实现代理方法，必须自己dismiss
    ///适合用于头像选择 UIImagePickerControllerEditedImage
    /**
     关于内存，如果使用cocos2dx开发一个空白的模板游戏，内容占用是70M，ios的ui空白应用程序，19M
     一般应用程序，内存在100M左右都能接受
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        print(info)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let scaleImage = image.scaleToWith(width: 600)
        //将图像添加到数组
        //判断当前选中的索引是否超出数组上限
        if selectedIndex >= pictures.count {
            pictures.append(scaleImage)

        } else {
            pictures[selectedIndex] = scaleImage
        }
        //刷新视图
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
//MARK: - PicturePickerCellDelegate
//如果协议是私用的，在实现函数方法时，也是私有的
@objc
protocol PicturePickerCellDelegate: NSObjectProtocol {
    
    ///添加照片
    //要添加optional 关键字协议和方法都要遵守objc
    @objc optional func picturePickerCellDidAdd(cell: PicturePickerCell)
    ///删除照片
    @objc optional func picturePickerCellDidRemove(cell: PicturePickerCell)
}
///照片选择cell
class PicturePickerCell: UICollectionViewCell {
    ///照片选择代理
    weak var picturePickerDelegate: PicturePickerCellDelegate?
    var image: UIImage? {
        didSet {
            addButton.setImage(image ?? UIImage(named: "compose_pic_add"), for: .normal)
            //隐藏删除按钮 image == nil 就是新增按钮
            removeButton.isHidden = (image == nil)
        }
    }
    //MARK: - 监听方法
    @objc func addPicture() {
        //用问号判断是否实现了这个函数
        picturePickerDelegate?.picturePickerCellDidAdd?(cell: self)
    }
    @objc func removePicture() {
        picturePickerDelegate?.picturePickerCellDidRemove?(cell: self)
    }
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        addButton.frame = bounds
        removeButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
        }
        //监听方法
        addButton.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removePicture), for: .touchUpInside)
        //设置填充模式，如果button的mode没用，试试imageview的mode
        addButton.imageView?.contentMode = .scaleAspectFill
    }
    //MARK: - 懒加载控件
    lazy var addButton: UIButton = UIButton(imageName: "compose_pic_add", backImageName: nil)
    lazy var removeButton: UIButton = UIButton(imageName: "compose_photo_close", backImageName: nil)
    
}
