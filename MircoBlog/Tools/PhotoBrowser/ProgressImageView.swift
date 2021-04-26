//
//  ProgressImageView.swift
//  MircoBlog
//
//  Created by apple on 2021/4/26.
//

import UIKit
///带进度的图像视图
class ProgressImageView: UIImageView {
    ///进度值 0～1
    var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
        }
    }
    //rect  = bounds
    //面试图：如果在uiimageview的drawrect中绘图会怎么样 答案 不会执行drawrect，但是可以自定义uiview，会调用
    //一旦给构造函数指定了参数，系统就不再提供默认的构造函数
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(progressView)
        progressView.backgroundColor = UIColor.clear
        progressView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.snp.edges)
        }
    }
    
    private lazy var progressView: ProgressView = ProgressView()
    

}
private class ProgressView: UIView {
    ///内部使用的进度值 0～1
    var progress: CGFloat = 0 {
        didSet {
            //重绘视图
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let r = min(rect.width, rect.height) * 0.5
        //起始点默认在三点钟方向
        let start = CGFloat(-Double.pi/2)
        let end = start + progress * 2 * CGFloat(Double.pi)
        /**
         center 中心点
         radius 半径
         startAngle 起始弧度
         endAngle 截止弧度
         clockwise 是否顺时针
         */
        let path = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
        path.addLine(to: center)
        path.close()
        UIColor(white: 1.0, alpha: 0.3).setFill()
//        UIColor.red.setFill()
        path.fill()
        
    }
}
