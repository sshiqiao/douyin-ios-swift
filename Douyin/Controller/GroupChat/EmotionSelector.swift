//
//  EmotionSelector.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

let EMOTION_SELECTOR_HEIGHT:CGFloat = 220 + safeAreaBottomHeight
let EMOTION_CELL = "EmotionCell"

protocol EmotionSelectorDelegate:NSObjectProtocol {
    func onDelete()
    func onSend()
    func onSelect(emotionKey:String);
}
class EmotionSelector:UIView,UICollectionViewDelegate,UICollectionViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    var collectionView:UICollectionView?
    var delegate:EmotionSelectorDelegate?
    
    var itemWidth:CGFloat = 0
    var itemHeight:CGFloat = 0
    var data = [[String]]()
    var emotionDic = [String:String]()
    var pointViews = [UIView]()
    var currentIndex:Int = 0
    var bottomView = UIView.init()
    var send = UIButton.init()
    
    init() {
        super.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: EMOTION_SELECTOR_HEIGHT)))
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    func initSubView() {
        self.backgroundColor = ColorSmoke;
        self.clipsToBounds = false;
        emotionDic = EmotionHelper.emotionDic
        data = EmotionHelper.emotionArray
        
        itemWidth = screenWidth / 7.0
        itemHeight = 50
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top:0, left:0, bottom:0, right:0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize.init(width: itemWidth, height: itemHeight)
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: itemHeight * 3), collectionViewLayout: layout)
        collectionView?.backgroundColor = ColorClear
        collectionView?.alwaysBounceHorizontal = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(EmotionCell.classForCoder(), forCellWithReuseIdentifier: EMOTION_CELL)
        self.addSubview(collectionView!)
        
        currentIndex = 0
        let indicatorWith:CGFloat = 5
        let indicatorHeight:CGFloat = 5
        let indicatorSpacing:CGFloat = 8
        for index in 0..<data.count {
            let pointView = UIView.init(frame:CGRect.init(x:screenWidth/2 - (indicatorWith*CGFloat(data.count) + indicatorSpacing*CGFloat(data.count-1))/2 + (indicatorWith + indicatorSpacing)*CGFloat(index),y:(collectionView?.frame.height)!,width:indicatorWith,height:indicatorHeight))
            if currentIndex == index {
                pointView.backgroundColor = ColorThemeRed;
            }else {
                pointView.backgroundColor = ColorGray;
            }
            pointView.layer.cornerRadius = indicatorWith/2;
            pointViews.append(pointView)
            self.addSubview(pointView)
            
            bottomView = UIView.init(frame: CGRect.init(x: 0, y: (collectionView?.frame.height)! + 25, width: screenWidth, height: 45 + safeAreaBottomHeight))
            bottomView.backgroundColor = ColorWhite
            self.addSubview(bottomView)
            
            let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: itemWidth, height: 45 + safeAreaBottomHeight))
            leftView.backgroundColor = ColorSmoke
            bottomView.addSubview(leftView)
            
            let defaultEmotion = UIImageView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: itemWidth, height: 45)))
            defaultEmotion.contentMode = .center
            defaultEmotion.image = UIImage.init(named: "default_emoticon_cover")
            leftView.addSubview(defaultEmotion)
            
            send = UIButton.init(frame: CGRect.init(x: screenWidth - 60 - 15, y: 10, width: 60, height: 25))
            
            send.isEnabled = false
            send.backgroundColor = ColorSmoke
            send.layer.cornerRadius = 2
            send.titleLabel?.font = MediumFont
            send.setTitle("发送", for: .normal)
            send.tintColor = ColorWhite
            send.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            bottomView.addSubview(send)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePoints() {
        for index in 0..<pointViews.count {
            let pointView = pointViews[index]
            if currentIndex == index {
                pointView.backgroundColor = ColorThemeRed;
            }else {
                pointView.backgroundColor = ColorGray;
            }
        }
    }
    
    @objc func sendMessage() {
        delegate?.onSend()
    }
    
    func addTextViewObserver(textView:UITextView) {
        textView.addObserver(self, forKeyPath: "attributedText", options: .new, context: nil)
    }
    
    func removeTextViewObserver(textView:UITextView) {
        textView.removeObserver(self, forKeyPath: "attributedText");
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "attributedText" {
            let attributedString = change![NSKeyValueChangeKey.newKey] as? NSAttributedString
            if(attributedString != nil && (attributedString?.length ?? 0) > 0) {
                send.backgroundColor = ColorThemeRed
                send.isEnabled = true
            }else {
                send.backgroundColor = ColorSmoke
                send.isEnabled = false
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EMOTION_CELL, for: indexPath) as! EmotionCell
        let array:[String] = data[indexPath.section]
        if(indexPath.section < data.count - 1) {
            if(indexPath.row < array.count) {
                cell.initData(key: array[indexPath.row])
            }
        }else {
            if(indexPath.row % 3 != 2) {
                cell.initData(key: array[indexPath.row - indexPath.row/3])
            }
        }
        if(indexPath.row == 20) {
            cell.setDelte()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 20 {
            delegate?.onDelete()
        } else {
            let emotionKey = data[indexPath.section][indexPath.row]
            delegate?.onSelect(emotionKey: emotionKey)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let translatedPoint = scrollView.panGestureRecognizer.translation(in: scrollView)
        scrollView.panGestureRecognizer.isEnabled = false
        DispatchQueue.main.async {[weak self] in
            if(translatedPoint.x < 0 && (self?.currentIndex)! < (self?.data.count ?? 0) - 1) {
                self?.currentIndex += 1
            }
            if(translatedPoint.x > 0 && (self?.currentIndex)! > 0) {
                self?.currentIndex -= 1
            }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self?.updatePoints()
                self?.collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: self?.currentIndex ?? 0), at: .left, animated: false)
            }, completion: { finished in
                scrollView.panGestureRecognizer.isEnabled = true
            })
        }
    }
    
}

class EmotionCell:UICollectionViewCell {
    var emotion = UIImageView.init()
    
    var _isHighlighted:Bool = false
    override var isHighlighted: Bool {
        set {
            _isHighlighted = newValue
        }
        get {
            return false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        emotion.frame = self.bounds
        emotion.contentMode = .center
        self.contentView.addSubview(emotion)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setDelte() {
        emotion.image = UIImage.init(named: "iconLaststep")
    }
    
    func initData(key:String) {
        let emoticonsPath:String = Bundle.main.path(forResource: "Emoticons", ofType: "bundle") ?? ""
        let emotionPath = emoticonsPath + "/" + key
        emotion.image = UIImage.init(contentsOfFile: emotionPath)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
