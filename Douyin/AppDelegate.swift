//
//  AppDelegate.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/1.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import CoreTelephony
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController.init(rootViewController: UserHomePageController.init())
        window?.makeKeyAndVisible()
        
        AVPlayerManager.setAudioMode()
        NetworkManager.startMonitoring()
        WebSocketManger.shared().connect()
        requestPermission()

        VisitorRequest.saveOrFindVisitor(success: { data in
            let response = data as! VisitorResponse
            let visitor = response.data
            Visitor.write(visitor:visitor!)
        }, failure: { error in
            print("注册访客用户失败")
        })

        return true
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) in
            //process photo library request status.
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touchLocation = (event?.allTouches)?.first?.location(in: self.window)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        if statusBarFrame.contains(touchLocation!) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: StatusBarTouchBeginNotification), object: nil)
        }
    }
    
}

