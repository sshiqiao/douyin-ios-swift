//
//  CommentsPopView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
let COMMENT_CELL:String = "CommentCell"
class CommentsPopView:UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate, CommentTextViewDelegate {
    
    
    var label = UILabel.init()
    var close = UIImageView.init(image:UIImage.init(named: "icon_closetopic"))
    var awemeId:String?
    var visitor:Visitor = Visitor.read()
    
    var pageIndex:Int = 0
    var pageSize:Int = 20
    var container = UIView.init()
    var tableView = UITableView.init()
    var data = [Comment]()
    var textView = CommentTextView()
    var loadMore:LoadMoreControl?
    
    init(awemeId:String) {
        super.init(frame: screenFrame)
        self.awemeId = awemeId
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    
    func initSubView() {
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        container.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: screenHeight * 3 / 4)
        container.backgroundColor = ColorBlackAlpha60
        self.addSubview(container)
        
        let rounded = UIBezierPath.init(roundedRect: CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: screenHeight * 3 / 4)), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        container.layer.mask = shape
        
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
        visualEffectView.frame = self.bounds
        visualEffectView.alpha = 1.0
        container.addSubview(visualEffectView)
        
        label.frame = CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: 35))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "0条评论"
        label.textColor = ColorGray
        label.font = SmallFont
        container.addSubview(label)
        
        close.frame = CGRect.init(x: screenWidth - 40, y: 0, width: 30, height: 30)
        close.contentMode = .center
        close.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuesture(sender:))))
        container.addSubview(close)
        
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 35, width: screenWidth, height: screenHeight*3/4 - 35 - 50 - safeAreaBottomHeight), style: .grouped)
        tableView.backgroundColor = ColorClear
        tableView.tableHeaderView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: self.tableView.bounds.width, height: 0.01)))
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(CommentListCell.classForCoder(), forCellReuseIdentifier: COMMENT_CELL)
        container.addSubview(tableView)
        
        loadMore = LoadMoreControl.init(frame: CGRect.init(x: 0, y: 100, width: screenWidth, height: 50), surplusCount: 10)
        loadMore?.startLoading()
        loadMore?.onLoad = {[weak self] in
            self?.loadData(page: self?.pageIndex ?? 0)
        }
        tableView.addSubview(loadMore!)
        
        textView.delegate = self
        loadData(page: pageIndex)
    }
    
    func onSendText(text: String) {
        PostCommentRequest.postCommentText(aweme_id: awemeId ?? "", text: text, success: {[weak self] data in
            let response = data as? CommentResponse
            if let comment = response?.data {
                UIView.setAnimationsEnabled(false)
                self?.tableView.beginUpdates()
                self?.data.insert(comment, at: 0)
                var indexPaths = [IndexPath]()
                indexPaths.append(IndexPath.init(row: 0, section: 0))
                self?.tableView.insertRows(at: indexPaths, with: .none)
                self?.tableView.endUpdates()
                self?.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                UIView.setAnimationsEnabled(true)
            }
            UIWindow.showTips(text: "评论成功")
        }, failure: { error in
            UIWindow.showTips(text: "评论失败")
        })
    }
    
    func deleteComment(comment:Comment){
        DeleteCommentRequest.deleteComment(cid: comment.cid ?? "", success: {[weak self] data in
            if let index = self?.data.index(of:comment) {
                self?.tableView.beginUpdates()
                self?.data.remove(at: index)
                var indexPaths = [IndexPath]()
                indexPaths.append(IndexPath.init(row: index, section: 0))
                self?.tableView.deleteRows(at: indexPaths, with: .right)
                self?.tableView.endUpdates()
                UIWindow.showTips(text: "评论删除成功")
            } else {
                UIWindow.showTips(text: "评论删除失败")
            }
        }, failure: { error in
            UIWindow.showTips(text: "评论删除失败")
        })
    }
    
    func loadData(page:Int, _ size:Int = 20) {
        CommentListRequest.findCommentsPaged(aweme_id: awemeId ?? "", page: pageIndex, success: {[weak self] data in
            let response = data as! CommentListResponse
            let array = response.data
            
            self?.pageIndex += 1
            UIView.setAnimationsEnabled(false)
            self?.tableView.beginUpdates()
            self?.data += array
            var indexPaths = [IndexPath]()
            for row in ((self?.data.count ?? 0) - array.count)..<(self?.data.count ?? 0) {
                let indexPath = IndexPath.init(row: row, section: 0)
                indexPaths.append(indexPath)
            }
            self?.tableView.insertRows(at: indexPaths, with: .none)
            self?.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            self?.loadMore?.endLoading()
            if response.has_more == 0 {
                self?.loadMore?.loadingAll()
            }
            self?.label.text = String.init(response.total_count) + "条评论"
        }, failure: {[weak self] error in
            self?.loadMore?.loadingFailed()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommentListCell.cellHeight(comment: data[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_CELL) as! CommentListCell
        cell.initData(comment: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = data[indexPath.row]
        if !comment.isTemp && comment.user_type == "visitor" && MD5_UDID == comment.visitor?.udid {
            let menu = MenuPopView.init(titles: ["删除"])
            menu.onAction = {[weak self] index in
                self?.deleteComment(comment: comment)
            }
            menu.show()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.superview?.classForCoder)!).contains("CommentListCell")  {
            return false
        } else {
            return true
        }
    }
    
    @objc func handleGuesture(sender:UITapGestureRecognizer) {
        var point = sender.location(in: container)
        if !container.layer.contains(point) {
            dismiss()
        }
        point = sender.location(in: close)
        if close.layer.contains(point) {
            dismiss()
        }
    }
    
    func show() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.addSubview(self)
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            var frame = self.container.frame
            frame.origin.y = frame.origin.y - frame.size.height
            self.container.frame = frame
        }) { finished in
        }
        textView.show()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            var frame = self.container.frame
            frame.origin.y = frame.origin.y + frame.size.height
            self.container.frame = frame
        }) { finished in
            self.removeFromSuperview()
            self.textView.dismiss()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            self.frame = CGRect.init(x: 0, y: -offsetY, width: self.frame.width, height: self.frame.height)
        }
        if scrollView.isDragging && offsetY < -50 {
            dismiss()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CommentListCell:UITableViewCell {
    
    static let MaxContentWidth:CGFloat = screenWidth - 55 - 35
    
    var avatar = UIImageView.init(image: UIImage.init(named: "img_find_default"))
    var likeIcon = UIImageView.init(image: UIImage.init(named: "icCommentLikeBefore_black"))
    var nickName = UILabel.init()
    var extraTag = UILabel.init()
    var content = UILabel.init()
    var likeNum = UILabel.init()
    var date = UILabel.init()
    var splitLine = UIView.init()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        initSubViews()
    }
    
    func initSubViews() {
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 14
        self.addSubview(avatar)
        
        likeIcon.contentMode = .center
        self.addSubview(likeIcon)
        
        nickName.numberOfLines = 1
        nickName.textColor = ColorWhiteAlpha60
        nickName.font = SmallFont
        self.addSubview(nickName)
        
        content.numberOfLines = 0
        content.textColor = ColorWhiteAlpha80
        content.font = MediumFont
        self.addSubview(content)
        
        date.numberOfLines = 1
        date.textColor = ColorGray
        date.font = SmallFont
        self.addSubview(date)
        
        likeNum.numberOfLines = 1
        likeNum.textColor = ColorGray
        likeNum.font = SmallFont
        self.addSubview(likeNum)
        
        splitLine.backgroundColor = ColorWhiteAlpha10
        self.addSubview(splitLine)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.image = UIImage.init(named: "img_find_default")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.snp.makeConstraints { make in
            make.top.left.equalTo(self).inset(15)
            make.width.height.equalTo(28)
        }
        likeIcon.snp.makeConstraints { make in
            make.top.right.equalTo(self).inset(15)
            make.width.height.equalTo(20)
        }
        nickName.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self.avatar.snp.right).offset(10)
            make.right.equalTo(self.likeIcon.snp.left).inset(25)
        }
        content.snp.makeConstraints { make in
            make.top.equalTo(self.nickName.snp.bottom).offset(5)
            make.left.equalTo(self.nickName)
            make.width.lessThanOrEqualTo(CommentListCell.MaxContentWidth)
        }
        date.snp.makeConstraints { make in
            make.top.equalTo(self.content.snp.bottom).offset(5)
            make.left.right.equalTo(self.nickName)
        }
        likeNum.snp.makeConstraints { make in
            make.centerX.equalTo(self.likeIcon)
            make.top.equalTo(self.likeIcon.snp.bottom).offset(5)
        }
        splitLine.snp.makeConstraints { make in
            make.left.equalTo(self.date)
            make.right.equalTo(self.likeIcon)
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
    
    func initData(comment:Comment) {
        var avatarUrl:URL?
        if comment.user_type == "user" {
            avatarUrl = URL.init(string: comment.user?.avatar_thumb?.url_list.first ?? "")
            nickName.text = comment.user?.nickname
        } else {
            avatarUrl = URL.init(string: comment.visitor?.avatar_thumbnail?.url ?? "")
            nickName.text = Visitor.formatUDID(udid: comment.visitor?.udid ?? "")
        }
        avatar.setImageWithURL(imageUrl: avatarUrl!) {[weak self] (image, error) in
            self?.avatar.image = image?.drawCircleImage()
        }
        content.text = comment.text
        date.text = Date.formatTime(timeInterval: TimeInterval(comment.create_time ?? 0))
        likeNum.text = String.formatCount(count: comment.digg_count ?? 0)
    }
    
    static func cellHeight(comment:Comment) -> CGFloat {
        let attributedString = NSMutableAttributedString.init(string: comment.text ?? "")
        attributedString.addAttributes([NSAttributedString.Key.font : MediumFont], range: NSRange.init(location: 0, length: attributedString.length))
        let size:CGSize = attributedString.multiLineSize(width: MaxContentWidth)
        return size.height + 30 + 30
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CommentTextViewDelegate:NSObjectProtocol {
    func onSendText(text:String)
}

class CommentTextView:UIView, UITextViewDelegate {
    
    
    var leftInset:CGFloat = 15
    var rightInset:CGFloat = 60
    var topBottomInset:CGFloat = 15
    
    var container = UIView.init()
    var textView = UITextView.init()
    var delegate:CommentTextViewDelegate?
    
    var textHeight:CGFloat = 0
    var keyboardHeight:CGFloat = 0
    var placeHolderLabel = UILabel.init()
    var atImageView = UIImageView.init(image: UIImage.init(named: "iconWhiteaBefore"))
    var visualEffectView = UIVisualEffectView.init()
    
    init() {
        super.init(frame: screenFrame)
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    
    func initSubView() {
        self.frame = screenFrame
        self.backgroundColor = ColorClear
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGuestrue(sender:))))
        
        self.addSubview(container)
        container.backgroundColor = ColorBlackAlpha40
        
        keyboardHeight = safeAreaBottomHeight
        
        textView = UITextView.init()
        textView.backgroundColor = ColorClear
        textView.clipsToBounds = false
        textView.textColor = ColorWhite
        textView.font = BigFont
        textView.returnKeyType = .send
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: topBottomInset, left: leftInset, bottom: topBottomInset, right: rightInset)
        textHeight = textView.font?.lineHeight ?? 0
        
        placeHolderLabel.frame = CGRect.init(x:LEFT_INSET, y:0, width:screenWidth - LEFT_INSET - RIGHT_INSET, height:50)
        placeHolderLabel.text = "有爱评论，说点儿好听的~"
        placeHolderLabel.textColor = ColorGray
        placeHolderLabel.font = BigFont
        textView.addSubview(placeHolderLabel)
//        textView.setValue(placeHolderLabel, forKey: "_placeholderLabel")

        atImageView.contentMode = .center
        textView.addSubview(atImageView)
        
        textView.delegate = self
        container.addSubview(textView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        atImageView.frame = CGRect.init(x: screenWidth - 50, y: 0, width: 50, height: 50)
        let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        container.layer.mask = shape
        
        updateTextViewFrame()
    }
    
    func updateTextViewFrame() {
        let textViewHeight = keyboardHeight > safeAreaBottomHeight ? textHeight + 2 * topBottomInset : (textView.font?.lineHeight ?? 0) + 2*topBottomInset
        textView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: textViewHeight)
        container.frame = CGRect.init(x: 0, y: screenHeight - keyboardHeight - textViewHeight, width: screenWidth, height: textViewHeight + keyboardHeight)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        keyboardHeight = notification.keyBoardHeight()
        updateTextViewFrame()
        atImageView.image = UIImage.init(named: "iconBlackaBefore")
        container.backgroundColor = ColorWhite
        textView.textColor = ColorBlack
        self.backgroundColor = ColorBlackAlpha60
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        keyboardHeight = safeAreaBottomHeight
        updateTextViewFrame()
        atImageView.image = UIImage.init(named: "iconWhiteaBefore")
        container.backgroundColor = ColorBlackAlpha40
        textView.textColor = ColorWhite
        self.backgroundColor = ColorClear
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let attributeText = NSMutableAttributedString.init(attributedString: textView.attributedText)
        if !textView.hasText {
            placeHolderLabel.isHidden = false
            textHeight = textView.font?.lineHeight ?? 0
        } else {
            placeHolderLabel.isHidden = true
            textHeight = attributeText.multiLineSize(width: screenWidth - leftInset - rightInset).height
        }
        updateTextViewFrame()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.onSendText(text: textView.text)
            textView.text = ""
            textHeight = textView.font?.lineHeight ?? 0
            textView.resignFirstResponder()
        }
        return true
    }
    
    @objc func handleGuestrue(sender:UITapGestureRecognizer) {
        let point = sender.location(in: textView)
        if !(textView.layer.contains(point)) {
            textView.resignFirstResponder()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            if hitView?.backgroundColor == ColorClear {
                return nil
            }
        }
        return hitView
    }
    
    func show() {
        let window = UIApplication.shared.delegate?.window as? UIWindow
        window?.addSubview(self)
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
