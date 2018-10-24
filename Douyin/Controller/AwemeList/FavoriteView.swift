//
//  FavoriteView.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/7.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class FavoriteView:UIView {
    
    var favoriteBefore = UIImageView.init(image: UIImage.init(named: "icon_home_like_before"))
    var favoriteAfter = UIImageView.init(image: UIImage.init(named: "icon_home_like_after"))
    
    init() {
        super.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 50, height: 45)))
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    
    func initSubView() {
        favoriteBefore.frame = self.frame
        favoriteBefore.contentMode = .center
        favoriteBefore.isUserInteractionEnabled = true
        favoriteBefore.tag = LIKE_BEFORE_TAP_ACTION
        favoriteBefore.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:))))
        self.addSubview(favoriteBefore)
        
        
        favoriteAfter.frame = self.frame
        favoriteAfter.contentMode = .center
        favoriteAfter.isUserInteractionEnabled = true
        favoriteAfter.tag = LIKE_AFTER_TAP_ACTION
        favoriteAfter.isHidden = true
        favoriteAfter.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:))))
        self.addSubview(favoriteAfter)
    }
    
    func startLikeAnim(isLike:Bool) {
        favoriteBefore.isUserInteractionEnabled = false
        favoriteAfter.isUserInteractionEnabled = false
        if isLike {
            let length:CGFloat = 30
            let duration:CGFloat = 0.5
            for index in 0..<6 {
                let layer = CAShapeLayer.init()
                layer.position = favoriteBefore.center
                layer.fillColor = ColorThemeRed.cgColor
                
                let startPath = UIBezierPath.init()
                startPath.move(to: CGPoint.init(x: -2, y: -length))
                startPath.addLine(to: CGPoint.init(x: 2, y: -length))
                startPath.addLine(to: .zero)
                
                let endPath = UIBezierPath.init()
                endPath.move(to: CGPoint.init(x: -2, y: -length))
                endPath.addLine(to: CGPoint.init(x: 2, y: -length))
                endPath.addLine(to: CGPoint.init(x: 0, y: -length))
                
                layer.path = startPath.cgPath
                layer.transform = CATransform3DMakeRotation(.pi / 3.0 * CGFloat(index), 0.0, 0.0, 1.0)
                self.layer.addSublayer(layer)
                
                let group = CAAnimationGroup.init()
                group.isRemovedOnCompletion = false
                group.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
                group.fillMode = CAMediaTimingFillMode.forwards
                group.duration = CFTimeInterval(duration)
                
                let scaleAnim = CABasicAnimation.init(keyPath: "transform.scale")
                scaleAnim.fromValue = 0.0
                scaleAnim.toValue = 1.0
                scaleAnim.duration = CFTimeInterval(duration * 0.2)
                
                let pathAnim = CABasicAnimation.init(keyPath: "path")
                pathAnim.fromValue = layer.path
                pathAnim.toValue = endPath.cgPath
                pathAnim.beginTime = CFTimeInterval(duration * 0.2)
                pathAnim.duration = CFTimeInterval(duration * 0.8)
                
                group.animations = [scaleAnim, pathAnim]
                layer.add(group, forKey: nil)
            }
            favoriteAfter.isHidden = false
            favoriteAfter.alpha = 0.0
            favoriteAfter.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform.init(rotationAngle: .pi / 3 * 2))
            UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
                self.favoriteBefore.alpha = 0.0
                self.favoriteAfter.alpha = 1.0
                self.favoriteAfter.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0).concatenating(CGAffineTransform.init(rotationAngle: 0))
            }) { finished in
                self.favoriteBefore.alpha = 1.0
                self.favoriteBefore.isUserInteractionEnabled = true
                self.favoriteAfter.isUserInteractionEnabled = true
            }
        } else {
            favoriteAfter.alpha = 1.0
            favoriteAfter.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0).concatenating(CGAffineTransform.init(rotationAngle: 0))
            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseIn, animations: {
                self.favoriteAfter.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform.init(rotationAngle: .pi/4))
            }) { finished in
                self.favoriteAfter.isHidden = true
                self.favoriteBefore.isUserInteractionEnabled = true
                self.favoriteAfter.isUserInteractionEnabled = true
            }
        }
    }
    
    func resetView() {
        favoriteBefore.isHidden = false
        favoriteAfter.isHidden = true
        self.layer.removeAllAnimations()
    }
    
    
    @objc func handleGesture(sender:UITapGestureRecognizer) {
        switch sender.view?.tag {
        case LIKE_BEFORE_TAP_ACTION:
            startLikeAnim(isLike: true)
            break
        case LIKE_AFTER_TAP_ACTION:
            startLikeAnim(isLike: false)
            break
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
