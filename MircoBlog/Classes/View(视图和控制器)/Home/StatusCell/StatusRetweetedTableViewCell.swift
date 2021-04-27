//
//  StatusRetweetedTableViewCell.swift
//  MircoBlog
//
//  Created by apple on 2021/4/19.
//

import UIKit
///转发微博的cell
class StatusRetweetedTableViewCell: StatusTableViewCell {
    //重写属性 需要override，不需要super，先执行父类的didset，再执行子类的didset，只关心子类的didset
    ///微博视图模型
    override var viewModel: StatusViewModel? {
        didSet {
            retweetedLabel.text = viewModel?.retweetedText
            pictureView.snp.updateConstraints { (make) in
                let offset = viewModel?.thumbnailUrls?.count ?? 0 > 0 ? StatusCellMargin : 0
                make.top.equalTo(retweetedLabel.snp.bottom).offset(offset)
            }
        }
    }
    //MARK: - 懒加载控件
    //背景按钮
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return button
    }()
    //转发标签
    private lazy var retweetedLabel: UILabel = UILabel(title: "转发微博转发微博转发微博转发微博转发微博转发微博转发微博转发微博转发微博转发微博转发微博",
                                                       fontSize: 14,
                                                       color: UIColor.darkGray,
                                                       screenInset: StatusCellMargin)
    
}
//MARK: - 设置界面
extension StatusRetweetedTableViewCell {
    override func setupUI() {
        super.setupUI()
        //添加控件
        //在某个控件下面
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(retweetedLabel, aboveSubview: backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.bottom.equalTo(bottomView.snp.top)
        }
        retweetedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.top).offset(StatusCellMargin)
            make.left.equalTo(backButton.snp.left).offset(StatusCellMargin)
        }
        //配图视图
        pictureView.snp.makeConstraints { (make) in
            make.top.equalTo(retweetedLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(retweetedLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
        pictureView.backgroundColor = UIColor.clear
    }
}
