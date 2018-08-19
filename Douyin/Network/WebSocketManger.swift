//
//  WebSocketManger.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/3.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import Starscream

let WebSocketDidReceiveMessageNotification:String = "WebSocketDidReceiveMessageNotification"

let MaxReConnectCount = 5

class WebSocketManger:NSObject {
    
    var reOpenCount:Int = 0
    
    let websocket = { () -> WebSocket in
        var components = URLComponents.init(url: URL.init(string: BaseUrl + "/groupchat")!, resolvingAgainstBaseURL: false)
        components?.scheme = "ws"
        let url = components?.url
        var request = URLRequest.init(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
        request.addValue(UDID, forHTTPHeaderField: "udid")
        let websocket = WebSocket.init(request: request)
        return websocket
    }()
    
    private static let instance = { () -> WebSocketManger in
        return WebSocketManger.init()
    }()
    
    private override init() {
        super.init()
        websocket.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onNetworkStatusChange(notification:)), name: Notification.Name(rawValue: NetworkStatesChangeNotification), object: nil)
    }
    
    class func shared() -> WebSocketManger {
        return instance
    }
    
    func connect() {
        if(websocket.isConnected) {
            disConnect()
        }
        websocket.connect()
    }
    
    func disConnect() {
        websocket.disconnect()
    }
    
    func reConnect() {
        if(websocket.isConnected) {
            disConnect()
        }
        connect()
    }
    
    func sendMessage(msg:String) {
        if(websocket.isConnected) {
            websocket.write(string: msg)
        }
    }
    
    @objc func onNetworkStatusChange(notification:NSNotification) {
        if(!NetworkManager.isNotReachableStatus(status: notification.object) && !(websocket.isConnected)) {
            reConnect()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WebSocketManger:WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.reOpenCount = 0
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if(NetworkManager.networkStatus() != .notReachable) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0 , execute: {
                if(self.websocket.isConnected) {
                    self.reOpenCount = 0
                    return
                }
                if(self.reOpenCount >= MaxReConnectCount) {
                    self.reOpenCount = 0
                    return
                }
                self.reConnect()
                self.reOpenCount += 1
            })
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WebSocketDidReceiveMessageNotification), object: text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
