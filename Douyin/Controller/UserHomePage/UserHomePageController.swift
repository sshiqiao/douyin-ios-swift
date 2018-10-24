//
//  UserHomePageController.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/1.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

var USER_INFO_HEADER_HEIGHT:CGFloat = 340 + statusBarHeight
var SLIDE_TABBAR_FOOTER_HEIGHT:CGFloat = 40


let USER_INFO_HEADER:String = "UserInfoHeader"
let SLIDE_TABBAR_FOOTER:String = "SlideTabBarFooter"
let AWEME_COLLECTION_CELL:String = "AwemeCollectionCell"

class UserHomePageController: BaseViewController {

    var collectionView:UICollectionView?
    var loadMore:LoadMoreControl?
    var selectIndex:Int = 0
    
    let uid:String = "97795069353"
    var user:User?
    
    var workAwemes = [Aweme]()
    var favoriteAwemes = [Aweme]()
    
    var pageIndex = 0;
    let pageSize = 21
    
    var tabIndex = 0
    var itemWidth:CGFloat = 0
    var itemHeight:CGFloat = 0
    
    let scalePresentAnimation = ScalePresentAnimation.init()
    let scaleDismissAnimation = ScaleDismissAnimation.init()
    let swipeLeftInteractiveTransition = SwipeLeftInteractiveTransition.init()
    
    var userInfoHeader:UserInfoHeader?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarTitleColor(color: ColorClear)
        self.setNavigationBarBackgroundColor(color: ColorClear)
        self.setStatusBarBackgroundColor(color: ColorClear)
        self.setStatusBarStyle(style: .lightContent)
        self.setStatusBarHidden(hidden: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNetworkStatusChange(notification:)), name: Notification.Name(rawValue: NetworkStatesChangeNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
    }
    
    func initCollectionView() {
        itemWidth = (screenWidth - CGFloat(Int(screenWidth) % 3)) / 3.0 - 1.0
        itemHeight =  itemWidth * 1.3
        
        let layout = HoverViewFlowLayout.init(navHeight: safeAreaTopHeight)
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 0;
        collectionView = UICollectionView.init(frame: screenFrame, collectionViewLayout: layout)
        collectionView?.backgroundColor = ColorClear
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(UserInfoHeader.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: USER_INFO_HEADER)
        collectionView?.register(SlideTabBarFooter.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLIDE_TABBAR_FOOTER)
        collectionView?.register(AwemeCollectionCell.classForCoder(), forCellWithReuseIdentifier: AWEME_COLLECTION_CELL)
        self.view.addSubview(collectionView!)
        
        loadMore = LoadMoreControl.init(frame: CGRect.init(x: 0, y: USER_INFO_HEADER_HEIGHT + SLIDE_TABBAR_FOOTER_HEIGHT, width: screenWidth, height: 50), surplusCount: 15)
        loadMore?.startLoading()
        loadMore?.onLoad = {[weak self] in
            self?.loadData(page: self?.pageIndex ?? 0)
        }
        collectionView?.addSubview(loadMore!)
    }
    
    @objc func onNetworkStatusChange(notification:NSNotification) {
        if !NetworkManager.isNotReachableStatus(status: NetworkManager.networkStatus()) {
            if user == nil {
                loadUserData()
            }
            if favoriteAwemes.count == 0 && workAwemes.count == 0 {
                loadData(page: pageIndex)
            }
        }
    }
    
    func loadUserData() {
        UserRequest.findUser(uid: uid, success: {[weak self] data in
            self?.user = data as? User
            self?.setNavigationBarTitle(title: self?.user?.nickname ?? "")
            self?.collectionView?.reloadSections(IndexSet.init(integer: 0))
        }, failure: { error in
            UIWindow.showTips(text: error.localizedDescription)
        })
    }
    
    func loadData(page:Int, _ size:Int = 21) {
        if tabIndex == 0 {
            AwemeListRequest.findPostAwemesPaged(uid: uid, page: page, size, success: {[weak self] data in
                if let response = data as? AwemeListResponse {
                    if self?.tabIndex != 0 {
                        return
                    }
                    let array = response.data
                    self?.pageIndex += 1
                    
                    UIView.setAnimationsEnabled(false)
                    self?.collectionView?.performBatchUpdates({
                        self?.workAwemes += array
                        var indexPaths = [IndexPath]()
                        for row in ((self?.workAwemes.count ?? 0) - array.count)..<(self?.workAwemes.count ?? 0) {
                            indexPaths.append(IndexPath.init(row: row, section: 1))
                        }
                        self?.collectionView?.insertItems(at: indexPaths)
                    }, completion: { finished in
                        UIView.setAnimationsEnabled(true)
                        self?.loadMore?.endLoading()
                        if response.has_more == 0 {
                            self?.loadMore?.loadingAll()
                        }
                    })
                }
            }, failure:{ error in
                self.loadMore?.loadingFailed()
            })
        } else {
            AwemeListRequest.findFavoriteAwemesPaged(uid: uid, page: page, size, success: {[weak self] data in
                if let response = data as? AwemeListResponse {
                    if self?.tabIndex != 1 {
                        return
                    }
                    let array = response.data
                    self?.pageIndex += 1
                    
                    UIView.setAnimationsEnabled(false)
                    self?.collectionView?.performBatchUpdates({
                        self?.favoriteAwemes += array
                        var indexPaths = [IndexPath]()
                        for row in ((self?.favoriteAwemes.count ?? 0) - array.count)..<(self?.favoriteAwemes.count ?? 0) {
                            indexPaths.append(IndexPath.init(row: row, section: 1))
                        }
                        self?.collectionView?.insertItems(at: indexPaths)
                    }, completion: { finished in
                        UIView.setAnimationsEnabled(true)
                        self?.loadMore?.endLoading()
                        if response.has_more == 0 {
                            self?.loadMore?.loadingAll()
                        }
                    })
                }
            }, failure: { error in
                self.loadMore?.loadingFailed()
            })
        }
    }
}

extension UserHomePageController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return tabIndex == 0 ? workAwemes.count : favoriteAwemes.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AWEME_COLLECTION_CELL, for: indexPath) as! AwemeCollectionCell
        let aweme:Aweme = tabIndex == 0 ? workAwemes[indexPath.row] : favoriteAwemes[indexPath.row]
        cell.initData(aweme: aweme)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: USER_INFO_HEADER, for: indexPath) as! UserInfoHeader
                userInfoHeader = header
                if let data = user {
                    header.initData(user: data)
                    header.delegate = self
                }
                return header
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLIDE_TABBAR_FOOTER, for: indexPath) as! SlideTabBarFooter
                footer.delegate = self
                footer.setLabel(titles: ["作品" + String(user?.aweme_count ?? 0),"喜欢" + String(user?.favoriting_count ?? 0)], tabIndex: tabIndex)
                return footer
            }
        }
        return UICollectionReusableView.init()
    }
    
    //UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        let controller = tabIndex == 0 ? AwemeListController.init(data: workAwemes, currentIndex: indexPath.row, page: pageIndex, size: pageSize, awemeType: .AwemeWork, uid: uid) : AwemeListController.init(data: favoriteAwemes, currentIndex: indexPath.row, page: pageIndex, size: pageSize, awemeType: .AwemeFavorite, uid: uid)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overCurrentContext
        self.modalPresentationStyle = .currentContext
        swipeLeftInteractiveTransition.wireToViewController(viewController: controller)
        self.present(controller, animated: true, completion: nil)
    }
    
    //UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.init(width:screenWidth, height:USER_INFO_HEADER_HEIGHT) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.init(width:screenWidth, height:SLIDE_TABBAR_FOOTER_HEIGHT) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: itemWidth, height: itemHeight)
    }
    
}

extension UserHomePageController: UIScrollViewDelegate {
    //实现UIScrollViewDelegate中的scrollViewDidScroll方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //获取当前控件y方向的偏移量
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            userInfoHeader?.overScrollAction(offsetY: offsetY)
        } else {
            userInfoHeader?.scrollToTopAction(offsetY: offsetY)
            updateNavigationTitle(offsetY: offsetY)
        }
    }
    
    func updateNavigationTitle(offsetY:CGFloat) {
        if USER_INFO_HEADER_HEIGHT - self.navagationBarHeight()*2 > offsetY {
            setNavigationBarTitleColor(color: ColorClear)
        }
        
        if USER_INFO_HEADER_HEIGHT - self.navagationBarHeight()*2 < offsetY && offsetY < USER_INFO_HEADER_HEIGHT - self.navagationBarHeight() {
            let alphaRatio = 1.0 - (USER_INFO_HEADER_HEIGHT - self.navagationBarHeight() - offsetY)/self.navagationBarHeight()
            self.setNavigationBarTitleColor(color: UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: alphaRatio))
        }
        
        if offsetY > USER_INFO_HEADER_HEIGHT - self.navagationBarHeight() {
            self.setNavigationBarTitleColor(color: ColorWhite)
        }
    }
}

extension UserHomePageController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return scalePresentAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return scaleDismissAnimation
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeLeftInteractiveTransition.interacting ? swipeLeftInteractiveTransition : nil
    }
}

extension UserHomePageController: UserInfoDelegate, OnTabTapActionDelegate {
    
    func onUserActionTap(tag: Int) {
        switch tag {
        case AVATAE_TAG:
            PhotoView.init(user?.avatar_medium?.url_list.first).show()
            break
        case SEND_MESSAGE_TAG:
            self.navigationController?.pushViewController(ChatListController.init(), animated: true)
            break
        case FOCUS_CANCEL_TAG,FOCUS_TAG:
            userInfoHeader?.startFocusAnimation()
            break
        case SETTING_TAG:
            let menu = MenuPopView.init(titles: ["清除缓存"])
            menu.onAction = { index in
                WebCacheManager.shared().clearCache { size in
                    UIWindow.showTips(text: "清除" + size + "M缓存")
                }
            }
            menu.show()
            break
        case GITHUB_TAG:
            UIApplication.shared.openURL(URL.init(string: "https://github.com/sshiqiao/douyin-ios-swift")!)
            break
        default:
            break
        }
    }
    
    func onTabTapAction(index: Int) {
        if tabIndex != index {
            tabIndex = index
            pageIndex = 0
            
            UIView.setAnimationsEnabled(false)
            collectionView?.performBatchUpdates({
                workAwemes.removeAll()
                favoriteAwemes.removeAll()
                collectionView?.reloadSections(IndexSet.init(integer: 1))
            }, completion: { finished in
                UIView.setAnimationsEnabled(true)
                
                self.loadMore?.reset()
                self.loadMore?.startLoading()
                
                self.loadData(page: self.pageIndex)
            })
        }
    }
}


