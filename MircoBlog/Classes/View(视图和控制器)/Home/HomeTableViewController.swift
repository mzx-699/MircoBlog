//
//  HomeTableViewController.swift
//  MircoBlog
//
//  Created by apple on 2021/4/1.
//

import UIKit
import SVProgressHUD
///微博cell ID
private let StatusCellNormalId = "StatusCellNormalId"

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
        tableView.register(StatusTableViewCell.self, forCellReuseIdentifier: StatusCellNormalId)
        
        //行高
        //预估行高
        tableView.estimatedRowHeight = 200
        //自动计算行高，需要一个自上而下的自动布局控件，指定一个向下的约束
        //1.从上往下计算空间位置
        //2.从下往上按照底部约束挤到最合适的约束
        tableView.rowHeight = UITableView.automaticDimension
    }
    ///加载属性
    private func loadData() {
        listViewModel.loadStatus { (isSuccessed) in
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
//            print(self.listViewModel.statusList)
            //刷新数据
            self.tableView.reloadData()
        }
    }
}

//MARK: - 数据源方法
extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusCellNormalId, for: indexPath) as! StatusTableViewCell
        cell.viewModel = listViewModel.statusList[indexPath.row]
        return cell
    }
}
