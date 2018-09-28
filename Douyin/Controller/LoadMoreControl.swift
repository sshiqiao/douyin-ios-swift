//
//  LoadMoreControl.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/5.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

typealias OnLoad = () -> Void

class LoadMoreControl:UIControl {
    
    var indicator: UIImageView = UIImageView.init(image: UIImage.init(named: "icon30WhiteSmall"))
    var label: UILabel = UILabel.init()
    
    var surplusCount: Int = 0
    var originalFrame: CGRect = .zero
    var superView: UIScrollView?
    var edgeInsets: UIEdgeInsets?
    
    private var _onLoad: OnLoad?
    var onLoad: OnLoad? {
        set {
            _onLoad = newValue
        }
        get {
            return _onLoad
        }
    }
    
    private var _loadingType: LoadingType = .LoadStateIdle
    var loadingType: LoadingType {
        set {
            _loadingType = newValue
            switch newValue {
            case .LoadStateIdle:
                self.isHidden = true
                break
            case .LoadStateLoading:
                self.isHidden = false
                indicator.isHidden = false
                label.text = "内容加载中..."
                label.snp.makeConstraints { make in
                    make.centerY.equalTo(self)
                    make.centerX.equalTo(self).offset(20)
                }
                indicator.snp.makeConstraints { make in
                    make.centerY.equalTo(self)
                    make.right.equalTo(self.label.snp.left).inset(-5)
                    make.width.height.equalTo(15)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1 , execute: {
                    self.startAnim()
                })
                break
            case .LoadStateAll:
                self.isHidden = false
                indicator.isHidden = true
                label.text = "没有更多了哦～"
                label.snp.makeConstraints { make in
                    make.center.equalTo(self)
                }
                stopAnim()
                updateFrame()
                break
            case .LoadStateFailed:
                self.isHidden = false
                indicator.isHidden = true
                label.text = "加载更多"
                label.snp.makeConstraints { make in
                    make.center.equalTo(self)
                }
                stopAnim()
                break
            }
        }
        get {
            return _loadingType
        }
    }
    
    init(frame:CGRect, surplusCount:Int) {
        super.init(frame: frame)
        self.surplusCount = surplusCount
        self.originalFrame = frame
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.originalFrame = frame
        initSubView()
    }
    
    func initSubView() {
        self.layer.zPosition = -1
        indicator.isHidden = true
        self.addSubview(indicator)
        
        label.text = "正在加载..."
        label.textColor = ColorGray
        label.font = SmallFont
        label.textAlignment = .center
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        superView = self.superview as? UIScrollView
        if edgeInsets == nil {
            edgeInsets = self.superView?.contentInset
            edgeInsets?.bottom += (50 + safeAreaBottomHeight)
            self.superView?.contentInset = edgeInsets ?? .zero
            superView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    
    func cellNumInTableView(tableView:UITableView) -> Int {
        var cellNum = 0
        for section in 0..<tableView.numberOfSections {
            let rowNum = tableView.numberOfRows(inSection: section)
            cellNum += rowNum
        }
        return cellNum
    }
    
    func cellNumInCollectionView(collectionView:UICollectionView) -> Int {
        var cellNum = 0
        for section in 0..<collectionView.numberOfSections {
            let rowNum = collectionView.numberOfItems(inSection: section)
            cellNum += rowNum
        }
        return cellNum
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            DispatchQueue.main.async {
                if (self.superView?.isKind(of: UITableView.classForCoder()))! {
                    if let tableView = self.superView as? UITableView {
                        let lastSection = tableView.numberOfSections - 1
                        if lastSection >= 0 {
                            let lastRow = tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1
                            if lastRow >= 0 {
                                if tableView.visibleCells.count > 0 {
                                    if let indexPath = tableView.indexPath(for: tableView.visibleCells.last!) {
                                        if indexPath.section == lastSection && indexPath.row >= lastRow - self.surplusCount {
                                            if self.loadingType == .LoadStateIdle || self.loadingType == .LoadStateFailed {
                                                self.startLoading()
                                                self.onLoad?()
                                            }
                                        }
                                        if indexPath.section == lastSection && indexPath.row == lastRow {
                                            self.frame = CGRect.init(x: 0, y: tableView.visibleCells.last?.frame.maxY ?? 0, width: screenWidth, height: 50)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (self.superView?.isKind(of: UICollectionView.classForCoder()))! {
                    if let collectionView = self.superView as? UICollectionView {
                        let lastSection = collectionView.numberOfSections - 1
                        if lastSection >= 0 {
                            let lastRow = collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1) - 1
                            if lastRow >= 0 {
                                if collectionView.visibleCells.count > 0 {
                                    let indexPaths = collectionView.indexPathsForVisibleItems
                                    let orderedIndexPaths = indexPaths.sorted(by: {$0.row < $1.row})
                                    if let indexPath = orderedIndexPaths.last {
                                        if indexPath.section == lastSection && indexPath.row >= lastRow - self.surplusCount {
                                            if self.loadingType == .LoadStateIdle || self.loadingType == .LoadStateFailed {
                                                self.startLoading()
                                                self.onLoad?()
                                            }
                                        }
                                        if indexPath.section == lastSection && indexPath.row == lastRow {
                                            if let cell = collectionView.cellForItem(at: indexPath) {
                                                self.frame = CGRect.init(x: 0, y: cell.frame.maxY, width: screenWidth, height: 50)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    
    func reset() {
        loadingType = .LoadStateIdle
        self.frame = originalFrame
    }
    
    func startLoading() {
        if loadingType != .LoadStateLoading {
            loadingType = .LoadStateLoading
        }
    }
    
    func endLoading() {
        if loadingType != .LoadStateIdle {
            loadingType = .LoadStateIdle
        }
    }
    
    func loadingFailed() {
        if loadingType != .LoadStateFailed {
            loadingType = .LoadStateFailed
        }
    }
    func loadingAll() {
        if loadingType != .LoadStateAll {
            loadingType = .LoadStateAll
        }
    }
    
    func updateFrame() {
        if (superView?.isKind(of: UITableView.classForCoder()))! {
            if let tableView = superView as? UITableView {
                let y:CGFloat = tableView.contentSize.height > originalFrame.origin.y ? tableView.contentSize.height : originalFrame.origin.y
                self.frame = CGRect.init(x: 0, y: y, width: screenWidth, height: 50)
            }
        }
        if (superView?.isKind(of: UICollectionView.classForCoder()))! {
            if let collectionView = superView as? UICollectionView {
                let y:CGFloat = collectionView.contentSize.height > originalFrame.origin.y ? collectionView.contentSize.height : originalFrame.origin.y
                self.frame = CGRect.init(x: 0, y: y, width: screenWidth, height: 50)
            }
        }
    }
    
    func startAnim() {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: .pi * 2.0)
        rotationAnimation.duration = 1.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = MAXFLOAT
        indicator.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnim() {
        indicator.layer.removeAllAnimations()
    }
    
    deinit {
        superView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}
