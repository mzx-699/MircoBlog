//
//  StatusTableViewCellBottomView.swift
//  MircoBlog
//
//  Created by apple on 2021/4/10.
//

import UIKit

///底部视图
class StatusTableViewCellBottomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载控件
    ///转发按钮
    private lazy var retweetedButton = UIButton(title: "  转发", fontSize: 12, color: UIColor.gray, imageName: "timeline_icon_retweet")
    ///评论按钮
    private lazy var commentButton = UIButton(title: "  评论", fontSize: 12, color: UIColor.gray, imageName: "timeline_icon_comment")
    ///点赞按钮
    private lazy var likeButton = UIButton(title: "  赞", fontSize: 12, color: UIColor.gray, imageName: "timeline_icon_unlike")

}

//MARK: - 设置界面
extension StatusTableViewCellBottomView {
    private func setupUI() {
        //设置背景颜色
        backgroundColor = UIColor(white: 0.9, alpha: 1)
        addSubview(retweetedButton)
        addSubview(commentButton)
        addSubview(likeButton)
        
        retweetedButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
        commentButton.snp.makeConstraints { (make) in
            make.top.equalTo(retweetedButton.snp.top)
            make.left.equalTo(retweetedButton.snp.right)
            make.width.equalTo(retweetedButton.snp.width)
            make.height.equalTo(retweetedButton.snp.height)
        }
        likeButton.snp.makeConstraints { (make) in
            make.top.equalTo(commentButton.snp.top)
            make.left.equalTo(commentButton.snp.right)
            make.width.equalTo(commentButton.snp.width)
            make.height.equalTo(commentButton.snp.height)
            make.right.equalTo(self.snp.right)
        }
        
        //分割视图
        let sep1 = sepView()
        let sep2 = sepView()
        addSubview(sep1)
        addSubview(sep2)
        
        let w = 0.5
        let scale = 0.4
        sep1.snp.makeConstraints { (make) in
            make.left.equalTo(retweetedButton.snp.right)
            make.centerY.equalTo(retweetedButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(retweetedButton.snp.height).multipliedBy(scale)
        }
        sep2.snp.makeConstraints { (make) in
            make.left.equalTo(commentButton.snp.right)
            make.centerY.equalTo(commentButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(commentButton.snp.height).multipliedBy(scale)
        }
    }
    
    ///创建分割视图
    //函数
    private func sepView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.darkGray
        return v
    }
    //此处如果使用计算型属性，会导致代码的阅读产生困难
    //计算型属性
//    private var sepView: UIView {
//        let v = UIView()
//        v.backgroundColor = UIColor.darkGray
//        return v
//    }
}
