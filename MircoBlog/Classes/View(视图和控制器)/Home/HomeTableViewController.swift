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
        
        
        loadData(offsetY: tableView.tableHeaderView!.bounds.height)
        //注册通知 通知中心始终存在对self有引用，只要监听到通知就会调用block，导致self无法被释放，一定要弱引用
        NotificationCenter.default.addObserver(forName: NSNotification.Name(WBStatusSelectedPhotoNotification), object: nil, //发送通知的对象
                                               queue: nil) { [weak self] (n) in
            //取值
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            //判断cell是否遵守了展现动画协议
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            //传递数据到浏览器
            let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
            //设置modal类型是自定义类型
            vc.modalPresentationStyle = .custom
            //设置动画代理
            vc.transitioningDelegate = self?.photoBrowsweAnimator
            //设置animator的代理参数
            self?.photoBrowsweAnimator.setDelegateParams(presentDelegate: cell, indexPath: indexPath, dismissDelegate: vc)
            //参数设置所有权交给调用方，一旦调用方失误漏传参数，可能造成错误；通过函数进行统一设置，保证传参正确，保证封装的完整性
            //self?.photoBrowsweAnimator.presentDelegate = cell
            //self?.photoBrowsweAnimator.indexPath = indexPath
            //self?.photoBrowsweAnimator.dismissDelegate = vc
//            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }
        //定时器
        dispatchTimer(timeInterval: 60, handler: { (_) in
            self.tableView.reloadData()
//            print("刷新数据")
        }, needRepeat: true)
        
    }
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
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
//        refreshControl = WBrefreshControl()
        
        tableView.tableHeaderView = headerView
        tableView.contentInset = UIEdgeInsets(top: -tableView.tableHeaderView!.bounds.height, left: 0, bottom: 0, right: 0)
        //上来刷新视图
        tableView.tableFooterView = pullupView
    }
    ///加载属性
    private func loadData(offsetY: CGFloat) {
//        refreshControl?.beginRefreshing()
        headerView.beginRefreshing()
        UIView.animate(withDuration: 0.5) {
            self.tableView.contentInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        }
        listViewModel.loadStatus(isPullup: pullupView.isAnimating) { (isSuccessed) in
            //关闭下拉刷新控件
//            self.refreshControl?.endRefreshing()
            self.headerView.endRefreshing()
            UIView.animate(withDuration: 1) {
                self.tableView.contentInset = UIEdgeInsets(top:-self.tableView.tableHeaderView!.bounds.height, left: 0, bottom: 0, right: 0)
            }
            //关闭上拉刷新
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
//            print(self.listViewModel.statusList)
            //显示下拉刷新提示
            self.showPulldownTip()
            //刷新数据
            self.tableView.reloadData()
            
        }
    }
    ///显示下拉刷新提示
    private func showPulldownTip() {
        guard let count = listViewModel.pulldownCount else {
            return
        }
        QL1("下拉刷新 \(count)")
        //添加提示 就近原则
        pulldownTipLabel.text = (count == 0) ? "没有新微博" : "刷新到 \(count) 条微博"
        let height: CGFloat = 30
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        pulldownTipLabel.frame = rect.offsetBy(dx: 0, dy: -3 * height + tableView.tableHeaderView!.bounds.height)
        
        //动画
        UIView.animate(withDuration: 1) {
            self.pulldownTipLabel.alpha = 0.7
            self.pulldownTipLabel.frame = rect.offsetBy(dx: 0, dy: self.tableView.tableHeaderView!.bounds.height)
        } completion: { (_) in
            UIView.animate(withDuration: 1) {
                self.pulldownTipLabel.frame = rect.offsetBy(dx: 0, dy: -3 * height)
                self.pulldownTipLabel.alpha = 0
            } completion: { (_) in
//                self.pulldownTipLabel.removeFromSuperview()
            }

        }

    }
    //MARK: - 懒加载控件
    ///下拉刷新提示标签
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18, color: UIColor.white)
        label.backgroundColor = UIColor.orange
        label.alpha = 0
        tableView.addSubview(label)
        return label
    }()
    //上拉刷新
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        return indicator
    }()
    ///照片查看专场动画代理
    private lazy var photoBrowsweAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
    private lazy var headerView = WBrefreshControl()
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
            loadData(offsetY: 0)
        }
        //设置cell的代理
        cell.cellDelegate = self
//        cell.contentView.layoutIfNeeded()
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
//        print("\(indexPath.row) : \(listViewModel.statusList[indexPath.row].rowHeight)")
        //视图模型
        return listViewModel.statusList[indexPath.row].rowHeight
    }
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

//        print("tableView.contentOffset.y + \(tableView.contentOffset.y)")
//        print("velocity.y + \(velocity.y)")
        if velocity.y < 0 && tableView.contentOffset.y < -tableView.tableHeaderView!.bounds.height {
//            print("tableView.contentOffset.y + \(tableView.contentOffset.y)")
            loadData(offsetY: -tableView.contentOffset.y)

        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("\(indexPath.row) : \(listViewModel.statusList[indexPath.row].rowHeight)")
    }
    
}

//MARK: - 定时器
extension HomeTableViewController {
    /// GCD实现定时器
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - handler: 事件
    ///   - needRepeat: 是否重复
    func dispatchTimer(timeInterval: Double, handler: @escaping (DispatchSourceTimer?) -> Void, needRepeat: Bool) {
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                if needRepeat {
                    handler(timer)
                } else {
                    timer.cancel()
                    handler(nil)
                }
            }
        }
        timer.resume()
        
    }
}

//MARK: - cellDelegate
extension HomeTableViewController: StatusCellDelegate {
    func statusCellDidclickUrl(url: URL) {
        //建立webview控制器
        let vc = HomeWebViewController(url: url)
        //隐藏下面的bar
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
