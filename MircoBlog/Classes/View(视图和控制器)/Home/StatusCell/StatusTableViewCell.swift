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
        }
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
    ///底部视图
    private lazy var bottomView: StatusTableViewCellBottomView = StatusTableViewCellBottomView()
    
}

//MARK: - 设置界面
extension StatusTableViewCell {
    
    private func setupUI() {
        //1.添加控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)

        //2.自动布局
        //顶部视图
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            // TODO: - 修改高度
            make.height.equalTo(StatusCellMargin + StatusCellIconWidth)
        }
        //内容标签
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left).offset(StatusCellMargin)
            //指定向下的约束
            make.bottom.equalTo(contentView.snp.bottom).offset(-StatusCellMargin)
        }
    }
}
