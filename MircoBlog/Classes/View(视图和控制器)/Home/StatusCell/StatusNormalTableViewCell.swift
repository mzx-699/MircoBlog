//
//  StatusNormalTableViewCell.swift
//  MircoBlog
//
//  Created by apple on 2021/4/19.
//

import UIKit
///原创微博
class StatusNormalTableViewCell: StatusTableViewCell {

    ///微博视图模型
    override var viewModel: StatusViewModel? {
        didSet {
            pictureView.snp.updateConstraints { (make) in
                //根据配图数量，决定配图视图的顶部间距
                let offset = viewModel?.thumbnailUrls?.count ?? 0 > 0 ? StatusCellMargin : 0
                make.top.equalTo(contentLabel.snp.bottom).offset(offset)
                
            }
        }
    }
    override func setupUI() {
        super.setupUI()
        //配图视图
        pictureView.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
    }

}
