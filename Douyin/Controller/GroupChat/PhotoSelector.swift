//
//  PhotoSelector.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation
import Photos

let PHOTO_SELECTOR_HEIGHT:CGFloat = 220 + safeAreaBottomHeight
let PHOTO_ITEM_HEIGHT:CGFloat = 170

protocol PhotoSelectorDelegate:NSObjectProtocol {
    func onSend(images:[UIImage])
}
class PhotoSelector:UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let PHOTO_CELL:String = "PhotoCell"
    
    let ALBUM_TAG:Int = 1000
    let ORIGINAL_PHOTO_TAG:Int = 2000
    let SEND_TAG:Int = 3000
    
    
    var container = UIView.init()
    var collectionView:UICollectionView?
    var delegate:PhotoSelectorDelegate?
    var data = [PHAsset]()
    var selectedData = [PHAsset]()
    var bottomView = UIView.init()
    var album = UIButton.init()
    var originalPhoto = UIButton.init()
    var send = UIButton.init()
    
    init() {
        super.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: PHOTO_SELECTOR_HEIGHT)))
        initSubView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    func initSubView() {
        
        self.backgroundColor = ColorSmoke;
        self.clipsToBounds = false;
        
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        result.enumerateObjects {[weak self] (asset, index, stop) in
            self?.data.append(asset)
            self?.collectionView?.reloadData()
        }
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top:0, left:0, bottom:0, right:0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2.5
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 2.5, width: screenWidth, height: PHOTO_ITEM_HEIGHT), collectionViewLayout: layout)
        collectionView?.backgroundColor = ColorClear
        collectionView?.alwaysBounceHorizontal = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(PhotoCell.classForCoder(), forCellWithReuseIdentifier: PHOTO_CELL)
        self.addSubview(collectionView!)
        
        bottomView.frame = CGRect.init(x: 0, y: (collectionView?.frame.maxY)! + 2.5, width: screenWidth, height: 45 + safeAreaBottomHeight)
        bottomView.backgroundColor = ColorWhite
        self.addSubview(bottomView)
        
        album = UIButton.init(frame: CGRect.init(x: 15, y: 10, width: 40, height: 25))
        album.tag = ALBUM_TAG
        album.titleLabel?.font = BigFont
        album.setTitle("相册", for: .normal)
        album.setTitleColor(ColorThemeRed, for: .normal)
        album.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        bottomView.addSubview(album)
        
        originalPhoto = UIButton.init(frame: CGRect.init(x: album.frame.maxX + 10, y: 10, width: 60, height: 25))
        originalPhoto.tag = ORIGINAL_PHOTO_TAG;
        originalPhoto.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 0)
        originalPhoto.titleLabel?.font = BigFont;
        originalPhoto.setTitle("原图", for: .normal)
        originalPhoto.setTitleColor(ColorThemeRed, for: .normal)
        originalPhoto.setImage(UIImage.init(named: "radio_button_unchecked_white"), for: .normal)
        originalPhoto.setImage(UIImage.init(named: "radio_button_checked_red"), for: .selected)
        originalPhoto.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -2, bottom: 0, right: 0)
        originalPhoto.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        bottomView.addSubview(originalPhoto)
        
        send = UIButton.init(frame: CGRect.init(x: screenWidth - 60 - 15, y: 10, width: 60, height: 25))
        send.tag = SEND_TAG;
        send.isEnabled = false
        send.backgroundColor = ColorSmoke
        send.layer.cornerRadius = 2
        send.titleLabel?.font = MediumFont
        send.setTitle("发送", for: .normal)
        send.setTitleColor(ColorWhite, for: .normal)
        send.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        bottomView.addSubview(send)
    }
    
    @objc func onButtonClick(sender:UIButton) {
        switch (sender.tag) {
        case ALBUM_TAG:
            break
        case ORIGINAL_PHOTO_TAG:
            originalPhoto.isSelected = !originalPhoto.isSelected
            break
        case SEND_TAG:
            self.processAssets()
            break
        default:
            break
        }
    }
    
    func processAssets() {
        if selectedData.count > 9 {
            UIWindow.showTips(text: "最多选择9张图片")
            return
        }
        if delegate != nil {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions.init()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            var images = [UIImage]()
            for asset in selectedData {
                let imageHeight:CGFloat = originalPhoto.isSelected ? CGFloat(asset.pixelHeight) : CGFloat(asset.pixelHeight > 1000 ? 1000 : asset.pixelHeight)
                manager.requestImage(for: asset, targetSize: CGSize.init(width:imageHeight * (CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)), height:imageHeight), contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (result, info) in
                    if let img = result {
                        images.append(img)
                    }
                    if images.count == self.selectedData.count {
                        self.delegate?.onSend(images: images)
                        self.selectedData.removeAll()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count > 50 ? 50 : data.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTO_CELL, for: indexPath) as! PhotoCell
        let asset = data[indexPath.row];
        cell.initData(asset: asset, selected: selectedData.contains(asset))
        cell.onSelect = {[weak self] isSelected in
            if isSelected {
                self?.selectedData.append(asset)
            } else {
                if let index = self?.selectedData.index(of: asset) {
                    self?.selectedData.remove(at: index)
                }
            }
            if self?.selectedData.count ?? 0 > 0 {
                self?.send.isEnabled = true
                self?.send.backgroundColor = ColorThemeRed
            } else {
                self?.send.isEnabled = false
                self?.send.backgroundColor = ColorSmoke
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let asset = data[indexPath.row];
        return CGSize.init(width: PHOTO_ITEM_HEIGHT*(CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)), height: PHOTO_ITEM_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

typealias OnSelect = (_ isSelected:Bool) -> Void
class PhotoCell:UICollectionViewCell {
    var photo = UIImageView.init()
    var checkbox = UIButton.init()
    var coverLayer = CALayer.init()
    var onSelect:OnSelect?
    
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
        photo.contentMode = .scaleAspectFill;
        self.contentView.addSubview(photo)
        
        coverLayer.backgroundColor = ColorBlackAlpha60.cgColor
        coverLayer.isHidden = true
        photo.layer.addSublayer(coverLayer)
        
        checkbox.setImage(UIImage.init(named: "radio_button_unchecked_white"), for: .normal)
        checkbox.setImage(UIImage.init(named: "check_circle_white"), for: .selected)
        checkbox.addTarget(self, action: #selector(selectCheckbox), for: .touchUpInside)
        self.contentView.addSubview(checkbox)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photo.image = nil
        coverLayer.isHidden = true
        checkbox.isSelected = false
        photo.transform = CGAffineTransform.identity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photo.frame = self.bounds
        
        photo.transform = checkbox.isSelected ? CGAffineTransform.init(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
        checkbox.frame = CGRect.init(x:self.bounds.size.width - 30, y:0, width:30, height:30)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        coverLayer.frame = photo.bounds
        CATransaction.commit()
    }
    
    func initData(asset:PHAsset, selected:Bool) {
        let manager = PHImageManager.default()
        if (self.tag != 0) {
            manager.cancelImageRequest(PHImageRequestID(self.tag))
        }
        manager.requestImage(for: asset, targetSize: CGSize.init(width:PHOTO_ITEM_HEIGHT * (CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)), height:PHOTO_ITEM_HEIGHT), contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (result, info) in
            self.photo.image = result
        })
        checkbox.isSelected = selected
        coverLayer.isHidden = !checkbox.isSelected
    }
    
    @objc func selectCheckbox() {
        checkbox.isSelected = !checkbox.isSelected
        coverLayer.isHidden = !checkbox.isSelected;
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.photo.transform = self.checkbox.isSelected ? CGAffineTransform.init(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
        }) { finished in
            
        }
        onSelect?(checkbox.isSelected)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
