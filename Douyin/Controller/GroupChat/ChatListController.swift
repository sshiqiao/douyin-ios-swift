//
//  ChatListController.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation


let TIME_CELL:String = "TIME_CELL"
let SYSTEM_MESSAGE_CELL:String = "SYSTEM_MESSAGE_CELL"
let IMAGE_MESSAGE_CELL:String = "IMAGE_MESSAGE_CELL"
let TEXT_MESSAGE_CELL:String = "TEXT_MESSAGE_CELL"

let SYS_MSG_CORNER_RADIUS:CGFloat = 10
let MAX_SYS_MSG_WIDTH:CGFloat = screenWidth - 110
let COMMON_MSG_PADDING:CGFloat = 8
let USER_MSG_CORNER_RADIUS:CGFloat = 10
let MAX_USER_MSG_WIDTH:CGFloat = screenWidth - 160
let MSG_IMAGE_CORNOR_RADIUS:CGFloat = 10
let MAX_MSG_IMAGE_WIDTH:CGFloat = 200
let MAX_MSG_IMAGE_HEIGHT:CGFloat = 200

class ChatListController: BaseViewController {
    
    var refreshControl = RefreshControl.init()
    var tableView:UITableView?
    var data = [GroupChat]()
    var textView = ChatTextView.init()
    
    var pageIndex = 0;
    let pageSize = 20
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarTitle(title: "QSHI")
        self.setNavigationBarTitleColor(color: ColorWhite)
        self.setNavigationBarBackgroundColor(color: ColorThemeGrayDark)
        self.setStatusBarBackgroundColor(color: ColorThemeGrayDark)
        self.setStatusBarStyle(style: .lightContent)
        self.setStatusBarHidden(hidden: false)
        textView.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData(page: pageIndex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.dismiss()
    }
    
    func setUpView() {
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: safeAreaTopHeight, width: screenWidth, height: screenHeight - (self.navagationBarHeight() + statusBarHeight) - 10 - safeAreaBottomHeight))
        tableView?.backgroundColor = ColorClear
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.alwaysBounceVertical = true
        tableView?.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView?.register(TimeCell.classForCoder(), forCellReuseIdentifier: TIME_CELL)
        tableView?.register(SystemMessageCell.classForCoder(), forCellReuseIdentifier: SYSTEM_MESSAGE_CELL)
        tableView?.register(ImageMessageCell.classForCoder(), forCellReuseIdentifier: IMAGE_MESSAGE_CELL)
        tableView?.register(TextMessageCell.classForCoder(), forCellReuseIdentifier: TEXT_MESSAGE_CELL)
        self.view.addSubview(tableView!)
        
        refreshControl.onRefresh = {[weak self] in
            self?.loadData(page: self?.pageIndex ?? 0)
        }
        tableView?.addSubview(refreshControl)
        
        textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage(notification:)), name: NSNotification.Name(rawValue: WebSocketDidReceiveMessageNotification), object: nil)
    }
    
    func loadData(page:Int, _ size:Int = 20) {
        GroupChatListRequest.findGroupChatsPaged(page: page, size, success: {[weak self] data in
            if let response = data as? GroupChatListResponse {
                let array = response.data
                let preCount = self?.data.count ?? 0
                UIView.setAnimationsEnabled(false)
                self?.processData(data: array)
                let curCount = self?.data.count ?? 0
                if (self?.pageIndex ?? 0) == 0 || preCount == 0 || (curCount - preCount) <= 0 {
                    self?.scrollToBottom()
                } else {
                    self?.tableView?.scrollToRow(at: IndexPath.init(row: curCount - preCount, section: 0), at: .top, animated: false)
                }
                self?.pageIndex += 1
                self?.refreshControl.endRefresh()
                if response.has_more == 0 {
                    self?.refreshControl.loadAll()
                }
                UIView.setAnimationsEnabled(true)
            }
        }, failure: {[weak self] error in
            self?.refreshControl.endRefresh()
        })
    }
    
    func processData(data:[GroupChat]) {
        if data.count == 0 {
            return
        }
        var tempArray = [GroupChat]()
        for chat in data {
            if (!("system" == chat.msg_type ?? "") &&
                (tempArray.count == 0 || (tempArray.count > 0 && (labs((tempArray.last?.create_time ?? 0) - (chat.create_time ?? 0)) > 60*5)))) {
                let timeChat = chat.createTimeChat()
                tempArray.append(timeChat)
            }
            chat.cellHeight = ChatListController.cellHeight(chat: chat)
            tempArray.append(chat)
        }
        self.data.insert(contentsOf: tempArray, at: 0)
        tableView?.reloadData()
    }
    
    func deleteChat(cell:UITableViewCell?) {
        if cell == nil {
            return
        }
        if let indexPath = tableView?.indexPath(for: cell!) {
            let index = indexPath.row
            if index < data.count {
                let chat = data[index]
                var indexPaths = [IndexPath]()
                if index - 1 < data.count && data[index - 1].msg_type == "time" {
                    indexPaths.append(IndexPath.init(row: index - 1, section: 0))
                }
                if index < data.count {
                    indexPaths.append(IndexPath.init(row: index, section: 0))
                }
                if indexPaths.count == 0 {
                    return
                }
                
                DeleteGroupChatRequest.deleteGroupChat(id: chat.id ?? "", success: {[weak self] data in
                    self?.tableView?.beginUpdates()
                    var indexs = [Int]()
                    for indexPath in indexPaths {
                        indexs.append(indexPath.row)
                    }
                    self?.data.removeAtIndexes(indexs: indexs)
                    self?.tableView?.deleteRows(at: indexPaths, with: .right)
                    self?.tableView?.endUpdates()
                }, failure: { error in
                    UIWindow.showTips(text: "删除失败")
                })
            }
        }
    }
    
    func scrollToBottom() {
        if self.data.count > 0 {
            tableView?.scrollToRow(at: IndexPath.init(row: self.data.count-1, section: 0), at: .bottom, animated: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ChatListController {
    @objc func receiveMessage(notification:Notification) {
        let json = notification.object as! String
        if let chat = GroupChat.deserialize(from: json) {
            chat.cellHeight = ChatListController.cellHeight(chat: chat)
            var shouldScrollToBottom = false
            if (tableView?.visibleCells.count)! > 0 && (tableView?.indexPath(for: (tableView?.visibleCells.last)!)?.row ?? 0) == data.count - 1 {
                shouldScrollToBottom = true
            }
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            data.append(chat)
            tableView?.insertRows(at: [IndexPath.init(row: data.count - 1, section: 0)], with: .none)
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if shouldScrollToBottom {
                scrollToBottom()
            }
        }
    }
}

extension ChatListController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chat = data[indexPath.row]
        return chat.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = data[indexPath.row]
        if chat.msg_type == "system" {
            let cell = tableView.dequeueReusableCell(withIdentifier: SYSTEM_MESSAGE_CELL) as! SystemMessageCell
            cell.initData(chat: chat)
            return cell
        } else if chat.msg_type == "text" {
            let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_MESSAGE_CELL) as! TextMessageCell
            cell.initData(chat: chat)
            cell.onMenuAction = {[weak self] actionType in
                if actionType == .DeleteAction {
                    self?.deleteChat(cell: cell)
                } else if actionType == .CopyAction {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = chat.msg_content;
                }
            }
            return cell
        } else if chat.msg_type == "image" {
            let cell = tableView.dequeueReusableCell(withIdentifier: IMAGE_MESSAGE_CELL) as! ImageMessageCell
            cell.initData(chat: chat)
            cell.onMenuAction = {[weak self] actionType in
                if actionType == .DeleteAction {
                    self?.deleteChat(cell: cell)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TIME_CELL) as! TimeCell
            cell.initData(chat: chat)
            return cell
        }
    }
    
    static func cellHeight(chat:GroupChat) -> CGFloat {
        if chat.msg_type == "system" {
            return SystemMessageCell.cellHeight(chat:chat)
        } else if chat.msg_type == "text" {
            return TextMessageCell.cellHeight(chat:chat)
        } else if chat.msg_type == "image" {
            return ImageMessageCell.cellHeight(chat:chat)
        } else {
            return TimeCell.cellHeight(chat:chat)
        }
    }
}

extension ChatListController:ChatTextViewDelegate {
    func onSendText(text: String) {
        let chat = GroupChat.initTextChat(text:text)
        chat.visitor = Visitor.read()
        chat.cellHeight = ChatListController.cellHeight(chat: chat)
        
        UIView.setAnimationsEnabled(false)
        tableView?.beginUpdates()
        data.append(chat)
        tableView?.insertRows(at: [IndexPath.init(row: data.count - 1, section: 0)], with: .none)
        tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        scrollToBottom()
        
        if let index = data.index(of: chat) {
            PostGroupChatTextRequest.postGroupChatText(text: text, success: {[weak self] data in
                if let response = data as? GroupChatResponse {
                    chat.updateTempTextChat(chat: response.data!)
                    self?.tableView?.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                }
            }, failure: {[weak self] error in
                chat.isCompleted = false
                chat.isFailed = true
                self?.tableView?.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
            })
        }
        
    }
    
    func onSendImages(images: [UIImage]) {
        for image in images {
            if let data:Data = image.jpegData(compressionQuality: 1.0) {
                let chat = GroupChat.initImageChat(image: image)
                chat.visitor = Visitor.read()
                chat.cellHeight = ChatListController.cellHeight(chat: chat)
                
                UIView.setAnimationsEnabled(false)
                tableView?.beginUpdates()
                self.data.append(chat)
                tableView?.insertRows(at: [IndexPath.init(row: self.data.count - 1, section: 0)], with: .none)
                tableView?.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                if let index = self.data.index(of: chat) {
                    PostGroupChatImageRequest.postGroupChatImage(data: data, {[weak self] percent in
                        chat.percent = Float(percent)
                        chat.isCompleted = false
                        chat.isFailed = false
                        if let cell = self?.tableView?.cellForRow(at: IndexPath.init(row: index, section: 0)) as? ImageMessageCell {
                            cell.updateUploadStatus(chat:chat)
                        }
                        }, success: {[weak self] data in
                            if let response = data as? GroupChatResponse {
                                chat.updateTempImageChat(chat: response.data!)
                                self?.tableView?.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                            }
                    }, failure: {[weak self] error in
                        chat.percent = 0
                        chat.isCompleted = false
                        chat.isFailed = true
                        if let cell = self?.tableView?.cellForRow(at: IndexPath.init(row: index, section: 0)) as? ImageMessageCell {
                            cell.updateUploadStatus(chat:chat)
                        }
                    })
                }
            }
        }
        scrollToBottom()
    }
    
    func onEditBoardHeightChange(height: CGFloat) {
        tableView?.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: height, right: 0)
        scrollToBottom()
    }
    
    
}


