//
//  ScaleDismissAnimation.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class ScaleDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let centerFrame = CGRect.init(x: (screenWidth - 5)/2, y: (screenHeight - 5)/2, width: 5, height: 5)
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! AwemeListController
        let toVC = transitionContext.viewController(forKey: .to) as! UINavigationController
        
        let userHomePageController = toVC.viewControllers.first as! UserHomePageController
        
        var snapshotView:UIView?
        var scaleRatio:CGFloat = 1.0
        var finalFrame:CGRect = centerFrame
        if let selectCell = userHomePageController.collectionView?.cellForItem(at: IndexPath.init(item: fromVC.currentIndex, section: 1)) {
            snapshotView = selectCell.snapshotView(afterScreenUpdates: false)
            scaleRatio = fromVC.view.frame.width/selectCell.frame.width
            snapshotView?.layer.zPosition = 20
            finalFrame = userHomePageController.collectionView?.convert(selectCell.frame, to: userHomePageController.collectionView?.superview) ?? centerFrame
        } else {
            snapshotView = fromVC.view.snapshotView(afterScreenUpdates: false)
            scaleRatio = fromVC.view.frame.width/screenWidth
            finalFrame = centerFrame
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(snapshotView!)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        fromVC.view.alpha = 0.0
        snapshotView?.center = fromVC.view.center
        snapshotView?.transform = CGAffineTransform.init(scaleX: scaleRatio, y: scaleRatio)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            snapshotView?.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            snapshotView?.frame = finalFrame
        }) { finished in
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(true)
            snapshotView?.removeFromSuperview()
        }
    }
    
    
}
