//
//  StatusTableViewCell.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import UIKit

///微博cell中控件的间距数值
let StatusCellMargin: CGFloat = 12
///微博头像宽度
let StatusCellIconWidth: CGFloat = 35

///微博cell
class StatusTableViewCell: UITableViewCell {
    
    ///微博视图模型
    var viewModel: StatusViewModel? {
        didSet {
            topView.viewModel = viewModel
            contentLabel.text = viewModel?.status.text
            //设置配图视图后，配图视图有能力计算大小
            pictureView.viewModel = viewModel
            //修改配图视图的高度 实际开发中，如果动态修改约束的高度，可能会导致行高计算有误
            //使用自动布局的时候，绝大多数问题，是因为约束加多了
            pictureView.snp.updateConstraints { (make) in
                make.height.equalTo(pictureView.bounds.height)
                //直接设置宽度数值
                make.width.equalTo(pictureView.bounds.width)
            }
        }
    }
    
    /// 根据指定的视图模型计算行高
    /// - Parameter vm: 视图模型
    /// - Returns: 返回视图模型对应的行高
    func rowHeight(vm: StatusViewModel) -> CGFloat {
        //记录视图模型 调用didset设置内容，更新约束
        viewModel = vm
        //强制更新所有约束，所有控件的frame都会被计算正确
        contentView.layoutIfNeeded()
        //返回底部视图最大高度
        return bottomView.frame.maxY
    }
    //MARK: - 构造函数
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载控件
    ///顶部视图
    private lazy var topView: StatusTableViewCellTopView = StatusTableViewCellTopView()
    ///微博正文标签
    private lazy var contentLabel: UILabel = UILabel(title: "微博正文", screenInset: StatusCellMargin, fontSize: 15)
    ///配图
    private lazy var pictureView: StatusPictureView = StatusPictureView()
    ///底部视图
    private lazy var bottomView: StatusTableViewCellBottomView = StatusTableViewCellBottomView()
    
}

//MARK: - 设置界面
extension StatusTableViewCell {
    
    private func setupUI() {
        //1.添加控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)

        //2.自动布局
        //顶部视图
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            // TODO: - 修改高度
            make.height.equalTo(2 * StatusCellMargin + StatusCellIconWidth)
        }
        //内容标签
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left).offset(StatusCellMargin)
            
        }
        //配图视图
        pictureView.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
        //底部视图
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(pictureView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(44)

        }
    }
}
