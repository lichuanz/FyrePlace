//
//  FriendTableViewCell.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-18.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var friend_photoImageView: UIImageView!

    @IBOutlet weak var friend_nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
