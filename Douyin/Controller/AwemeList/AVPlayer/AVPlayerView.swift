//
//  AVPlayerView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/6.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

//自定义Delegate，用于进度、播放状态更新回调
protocol AVPlayerUpdateDelegate:NSObjectProtocol {
    //播放进度更新回调方法
    func onProgressUpdate(current:CGFloat, total:CGFloat)
    //播放状态更新回调方法
    func onPlayItemStatusUpdate(status:AVPlayerItem.Status)
}

class AVPlayerView: UIView {
    
    var delegate:AVPlayerUpdateDelegate?    //代理
    
    var sourceURL:URL?                      //视频路径
    var sourceScheme:String?                   //路径Scheme
    var urlAsset:AVURLAsset?                //视频资源
    var playerItem:AVPlayerItem?            //视频资源载体
    var player:AVPlayer?                    //视频播放器
    var playerLayer:AVPlayerLayer = AVPlayerLayer.init()          //视频播放器图形化载体
    var timeObserver:Any?                   //视频播放器周期性调用的观察者
    
    var data:Data?                          //视频缓冲数据
    
    var session:URLSession?                 //视频下载session
    var task:URLSessionDataTask?            //视频下载NSURLSessionDataTask
    
    var response:HTTPURLResponse?           //视频下载请求响应
    var pendingRequests = [AVAssetResourceLoadingRequest]()  //存储AVAssetResourceLoadingRequest的数组
    
    var cacheFileKey:String?                                 //缓存文件key值
    var queryCacheOperation:Operation?                       //查找本地视频缓存数据的NSOperation
    
    var cancelLoadingQueue:DispatchQueue?
    
    init() {
        super.init(frame: screenFrame)
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    func initSubView() {
        session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.playerLayer)
        
        addProgressObserver()
        
        cancelLoadingQueue = DispatchQueue.init(label: "com.start.cancelloadingqueue")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = self.layer.bounds
        CATransaction.commit()
    }
    
    func setPlayerSourceUrl(url:String) {
        sourceURL = URL.init(string: url)
        
        var components = URLComponents.init(url: sourceURL!, resolvingAgainstBaseURL: false)
        sourceScheme = components?.scheme
        cacheFileKey = sourceURL?.absoluteString
        
        queryCacheOperation = WebCacheManager.shared().queryURLFromDiskMemory(key: cacheFileKey ?? "", cacheQueryCompletedBlock: { [weak self] (data, hasCache) in
            DispatchQueue.main.async {[weak self] in
                if !hasCache {
                    self?.sourceURL = self?.sourceURL?.absoluteString.urlScheme(scheme: "streaming")
                } else {
                    self?.sourceURL = URL.init(fileURLWithPath: data as? String ?? "")
                }
                if let url = self?.sourceURL {
                    self?.urlAsset = AVURLAsset.init(url: url, options: nil)
                    self?.urlAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
                    if let asset = self?.urlAsset {
                        self?.playerItem = AVPlayerItem.init(asset: asset)
                        self?.playerItem?.addObserver(self!, forKeyPath: "status", options: [.initial, .new], context: nil)
                        self?.player = AVPlayer.init(playerItem: self?.playerItem)
                        self?.playerLayer.player = self?.player
//                        self?.player.replaceCurrentItem(with: self?.playerItem)
                        self?.addProgressObserver()
                    }
                }
            }
        }, exten: "mp4")
    }
    
    func cancelLoading() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.isHidden = true
        CATransaction.commit()
        
        queryCacheOperation?.cancel()
        removeObserver()
        pause()
        
        player = nil
        playerItem = nil
        playerLayer.player = nil
        
        cancelLoadingQueue?.async {[weak self] in
            self?.urlAsset?.cancelLoading()
            
            self?.task?.cancel()
            self?.task = nil
            self?.data = nil
            self?.response = nil
            
            for loadingRequest in self?.pendingRequests ?? [] {
                if !loadingRequest.isFinished {
                    loadingRequest.finishLoading()
                }
            }
            self?.pendingRequests.removeAll()
        }
        
    }
    
    func updatePlayerState() {
        if player?.rate == 0 {
            play()
        } else {
            pause()
        }
    }
    
    func play() {
        AVPlayerManager.shared().play(player: player!)
    }
    
    func pause() {
        AVPlayerManager.shared().pause(player: player!)
    }
    
    func replay() {
        AVPlayerManager.shared().replay(player: player!)
    }
    
    func rate() -> CGFloat {
        return CGFloat(player?.rate ?? 0)
    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AVPlayerView {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerItem?.status == .readyToPlay {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                playerLayer.isHidden = false
                CATransaction.commit()
            }
            delegate?.onPlayItemStatusUpdate(status: playerItem?.status ?? AVPlayerItem.Status.unknown)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func addProgressObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: DispatchQueue.main, using: {[weak self] time in
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(self?.playerItem?.duration ?? CMTime.init())
            if total == current {
                self?.replay()
            }
            self?.delegate?.onProgressUpdate(current: CGFloat(current), total: CGFloat(total))
        })
    }
    
    func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    
}

extension AVPlayerView: URLSessionTaskDelegate, URLSessionDataDelegate {
    //网络资源下载请求获得响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = dataTask.response as! HTTPURLResponse
        let code = httpResponse.statusCode
        if(code == 200) {
            completionHandler(URLSession.ResponseDisposition.allow)
            self.data = Data.init()
            self.response = httpResponse
            self.processPendingRequests()
        }else {
            completionHandler(URLSession.ResponseDisposition.cancel)
        }
    }
    
    //接收网络资源下载数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data?.append(data)
        self.processPendingRequests()
    }
    
    //网络资源下载请求完毕
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            WebCacheManager.shared().storeDataToDiskCache(data: self.data, key: self.cacheFileKey ?? "", exten: "mp4")
        } else {
            print("AVPlayer resouce download error:" + error.debugDescription)
        }
    }
    
    //网络缓存数据复用
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        let cachedResponse = proposedResponse
        if dataTask.currentRequest?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData || dataTask.currentRequest?.url?.absoluteString == self.task?.currentRequest?.url?.absoluteString {
            completionHandler(nil)
        }else {
            completionHandler(cachedResponse)
        }
    }
    
    func processPendingRequests() {
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in self.pendingRequests {
            let didRespondCompletely = respondWithDataForRequest(loadingRequest: loadingRequest)
            if didRespondCompletely {
                requestsCompleted.append(loadingRequest)
                loadingRequest.finishLoading()
            }
        }
        for completedRequest in requestsCompleted {
            if let index = pendingRequests.index(of: completedRequest) {
                pendingRequests.remove(at: index)
            }
        }
    }
    
    func respondWithDataForRequest(loadingRequest:AVAssetResourceLoadingRequest) -> Bool {
        let mimeType = self.response?.mimeType ?? ""
        let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentType = contentType?.takeRetainedValue() as String?
        loadingRequest.contentInformationRequest?.contentLength = (self.response?.expectedContentLength)!
        
        var startOffset:Int64 = loadingRequest.dataRequest?.requestedOffset ?? 0
        if loadingRequest.dataRequest?.currentOffset != 0 {
            startOffset = loadingRequest.dataRequest?.currentOffset ?? 0
        }
        
        if Int64(data?.count ?? 0)  < startOffset {
            return false
        }
        
        let unreadBytes:Int64 = Int64(data?.count ?? 0) - (startOffset)
        let numberOfBytesToRespondWidth:Int64 = min(Int64(loadingRequest.dataRequest?.requestedLength ?? 0), unreadBytes)
        if let subdata = (data?.subdata(in: Int(startOffset)..<Int(startOffset + numberOfBytesToRespondWidth)))  {
            loadingRequest.dataRequest?.respond(with: subdata)
            let endOffset:Int64 = startOffset + Int64(loadingRequest.dataRequest?.requestedLength ?? 0)
            return Int64(data?.count ?? 0) >= endOffset
        }
        return false
    }
}

extension AVPlayerView: AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil {
            if let url = loadingRequest.request.url?.absoluteString.urlScheme(scheme: sourceScheme ?? "http") {
                let request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
                task = session?.dataTask(with: request)
                task?.resume()
            }
        }
        pendingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = pendingRequests.index(of: loadingRequest) {
            pendingRequests.remove(at: index)
        }
    }
    
}
