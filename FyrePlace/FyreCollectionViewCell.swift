//
//  FyreCollectionViewCell.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-01.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class FyreCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var group_photoImageView: UIImageView!
    
    @IBOutlet weak var group_sizeLabel: UILabel!
    
    @IBOutlet weak var group_nameLabel: UILabel!
    
    @IBOutlet weak var group_optionImageView: UIImageView!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    
    // MARK: Action
    
    // Puts checkmark icon when a cell is selected
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                super.selected = true
                self.selectionImageView.image = UIImage(named: "checkmark")
            } else if newValue == false {
                super.selected = false
                self.selectionImageView.image = nil
            }
        }
    }
    
    
}
