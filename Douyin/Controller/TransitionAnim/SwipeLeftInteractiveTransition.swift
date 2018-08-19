//
//  SwipeLeftInteractiveTransition.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class SwipeLeftInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var interacting:Bool = false
    var presentingVC:UIViewController?
    var viewControllerCenter:CGPoint = .zero
    
    func wireToViewController(viewController:AwemeListController) {
        presentingVC = viewController
        presentingVC?.view.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handlerGesture(gestureRecognizer:))))
        viewControllerCenter = presentingVC?.view.center ?? CGPoint.init(x: screenWidth/2, y: screenHeight/2)
    }
    
    override var completionSpeed: CGFloat {
        set {}
        get {
            return 1 - self.percentComplete
        }
    }
    
    @objc func handlerGesture(gestureRecognizer:UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        if !interacting && (translation.x < 0 || translation.y < 0 || translation.x < translation.y) {
            return
        }
        switch gestureRecognizer.state {
        case .began:
            interacting = true
            break
        case .changed:
            var progress:CGFloat = translation.x / screenWidth
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            
            let ratio:CGFloat = 1.0 - (progress * 0.5)
            presentingVC?.view.center = CGPoint.init(x: viewControllerCenter.x + translation.x * ratio, y: viewControllerCenter.y + translation.y * ratio)
            presentingVC?.view.transform = CGAffineTransform.init(scaleX: ratio, y: ratio)
            update(progress)
            break
        case .cancelled, .ended:
            var progress:CGFloat = translation.x / screenWidth
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            
            if progress < 0.2 {
                UIView.animate(withDuration: TimeInterval(progress), delay: 0.0, options: .curveEaseOut, animations: {
                    self.presentingVC?.view.center = CGPoint.init(x: screenWidth / 2, y: screenHeight / 2)
                    self.presentingVC?.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                }) { finished in
                    self.interacting = false
                    self.cancel()
                }
            }else {
                interacting = false
                finish()
                presentingVC?.dismiss(animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
}
