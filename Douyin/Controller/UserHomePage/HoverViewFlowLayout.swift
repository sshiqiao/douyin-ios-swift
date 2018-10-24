//
//  HoverViewFlowLayout.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/4.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class HoverViewFlowLayout: UICollectionViewFlowLayout {
    var navHeight:CGFloat = 0
    
    init(navHeight:CGFloat) {
        super.init()
        self.navHeight = navHeight
    }
    
    //重写layoutAttributesForElementsInRect方法
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var superArray:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect)!
        
        //移除掉所有Header和Footer类型的元素，因为抖音个人主页中只有第一个section包含Header和Footer类型元素，即移除需要固定的Header和Footer，因为后续会单独添加，为了避免重复处理。
        let copyArray = superArray
        for index in 0..<copyArray.count {
            let attributes = copyArray[index]
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader || attributes.representedElementKind == UICollectionView.elementKindSectionFooter {
                if let idx = superArray.index(of: attributes) {
                    superArray.remove(at: idx)
                }
            }
        }
        
        //单独添加上一步移除的Header和Footer，单独添加是因为第一步只能获取当前在屏幕rect中显示的元素属性，当第一个Sectioin移除屏幕便无法获取Header和Footer，这是需要单独添加Header和Footer以及第二部单独移除Header和Footer的原因。
        if let header = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(item: 0, section: 0)) {
            superArray.append(header)
        }
        if let footer = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath.init(item: 0, section: 0)) {
            superArray.append(footer)
        }
        
        //循环当前获取的元素
        for attributes in superArray {
            //判断是否是第一个section
            if attributes.indexPath.section == 0 {
                //判断是否为Header类型
                if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                    //获取Header的Frame
                    var rect = attributes.frame
                    //判断Header的bottom是否滑动到导航栏下方
                    if (self.collectionView?.contentOffset.y)! + self.navHeight - rect.size.height > rect.origin.y {
                        //修改Header frame的y值
                        rect.origin.y = (self.collectionView?.contentOffset.y)! + self.navHeight - rect.size.height
                        attributes.frame = rect
                    }
                    //设施Header层级，保证Header显示时不被其它cell覆盖
                    attributes.zIndex = 5
                }
                
                //判断是否为Footer类型
                if attributes.representedElementKind == UICollectionView.elementKindSectionFooter {
                    //获取Footer的Frame
                    var rect = attributes.frame
                    //判断Footer的top是否滑动到导航栏下方
                    if (self.collectionView?.contentOffset.y)! + self.navHeight > rect.origin.y {
                        //修改Footer frame的y值
                        rect.origin.y = (self.collectionView?.contentOffset.y)! + self.navHeight
                        attributes.frame = rect
                    }
                    //设施Footer层级，保证Footer显示时不被其它cell覆盖，同时显示在Header之上
                    attributes.zIndex = 10
                }
            }
        }
        //返回修改后的元素属性
        return superArray
    }
    
    //重写shouldInvalidateLayoutForBoundsChange方法
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
