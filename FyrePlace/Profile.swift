//
//  Profile.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-17.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class Profile: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String
    var photo: UIImage?
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("profiles")
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?) {
        self.name = name
        self.photo = photo
        
        super.init()
        
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
    }
    
    // Initializer for loading previously saved/encoded data
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        // Must call the designated initializer for this class
        self.init(name: name, photo: photo)
    }
    
}

