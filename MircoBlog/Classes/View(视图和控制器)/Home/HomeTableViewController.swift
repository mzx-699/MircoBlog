//
//  HomeTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit
import SVProgressHUD
///原创微博cell ID
let StatusCellNormalId = "StatusCellNormalId"
///转发微博的可重用id
let StatusCellRetweetedId = "StatusCellRetweetedId"
class HomeTableViewController: VisitorTableViewController {
    
    ///微博数据列表模型
    private lazy var listViewModel = StatusListViewModel()
    ///微博数据数组
    var dataList: [Status]?
    
    //调用访客视图didload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: "关注一些人，回这里看看有什么惊喜")
            return
        }
        prepareTableView()
        loadData()
        
    }
    ///准备表格
    private func prepareTableView() {
        //注册可重用cell
        tableView.register(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.register(StatusRetweetedTableViewCell.self, forCellReuseIdentifier: StatusCellRetweetedId)
        
        //取消分隔线
        tableView.separatorStyle = .none
        //行高
        //预估行高
        tableView.estimatedRowHeight = 400
        //自动计算行高，需要一个自上而下的自动布局控件，指定一个向下的约束
        //1.从上往下计算空间位置
        //2.从下往上按照底部约束挤到最合适的约束
//        tableView.rowHeight = UITableView.automaticDimension
        
        //navbar 44 tabbar 49
        //下来刷新 下来刷新控件默认没有 高度60
        refreshControl = WBrefreshControl()

        //上来刷新视图
        tableView.tableFooterView = pullupView
    }
    ///加载属性
    @objc private func loadData() {
        refreshControl?.beginRefreshing()
        listViewModel.loadStatus(isPullup: pullupView.isAnimating) { (isSuccessed) in
            //关闭下拉刷新控件
            self.refreshControl?.endRefreshing()
            //关闭上拉刷新
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
//            print(self.listViewModel.statusList)
            //刷新数据
            self.tableView.reloadData()
        }
    }
    //MARK: - 懒加载控件
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        return indicator
    }()
}

//MARK: - 数据源方法
extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        //会调用行高方法 没有indexpath参数的方法不会调用行高方法
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId!, for: indexPath) as! StatusTableViewCell
        cell.viewModel = vm
        //判断是否是最后一条微博
        if indexPath.row == listViewModel.statusList.count - 1 && !pullupView.isAnimating {
            pullupView.startAnimating()
            //上拉刷新数据
            loadData()
        }
        return cell
    }
    /**
     行高
     1.设置预估行高 当前显示的行高方法会调用三次
     执行顺序 行数 cell（每个cell都会调用行高）
     预估行高，要尽量靠近
     问题：预估行高不同，计算的次数不同 答：使用预估行高，计算出预估的contentSize，根据预估行高，判断计算次数，顺序计算每一行的行高，更新contentSize；如果预估行高过大，超出预估范围，顺序计算后续行高，一直到填满屏幕退出，同时更新contentSize；使用预估行高，每个cell的显示前需要计算，单个cell的效率是低的，从整体效率高

     2.没设置预估行高 计算所有行的高度，再计算显示行的高度*2
     执行顺序 行数 行高 显示cell
     问题：为什么要调用所有的行高方法，UITableView继承自UIScrollView，表格视图滚动非常流畅 -> contentSize要提前计算
     
     如果行高是固定值，就不要实现行高代理方法
     实际开发中，行高一定要缓存
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print(indexPath)
        //视图模型
        return listViewModel.statusList[indexPath.row].rowHeight
    }
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("tableView.contentOffset.y + \(tableView.contentOffset.y)")
        
        if velocity.y < 0 && tableView.contentOffset.y < -100{
//            print("velocity.y + \(velocity.y)")
            loadData()
            print("开始刷新")
        }
    }

}
