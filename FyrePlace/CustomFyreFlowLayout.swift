//
//  CustomFyreFlowLayout.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-02.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class CustomFyreFlowLayout: UICollectionViewFlowLayout {
    
    // This class is for defining a custom layout for the flow layout of collection view
    // The custom layout displays 3 cells per row in the collections view
    override init() {
        super.init()
        setupLayout()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    
    func setupLayout() {
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        scrollDirection = .Vertical
    }
    
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 3
            
            let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)*10) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }
    
}


