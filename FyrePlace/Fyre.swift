//
//  Fyre.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-05-29.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class Fyre: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name: String
    var owner: String
    var photo: UIImage?
    var option: String
    var size: Int
    var status: String
    var time: String
    
    // MARK: Types
    
    // Keys for stroring properties
    struct PropertyKey {
        static let nameKey = "name"
        static let ownerKey = "owner"
        static let photoKey = "photo"
        static let optionKey = "option"
        static let sizeKey = "size"
        static let statusKey = "status"
        static let timeKey = "time"
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("fyres")
    
    // MARK: Initialization
    init?(name: String, owner: String, photo: UIImage?, option: String, size: Int, status: String, time: String) {
        // Initialize the properties
        self.name = name
        self.owner = owner
        self.photo = photo
        self.option = option
        self.size = size
        self.status = status
        self.time = time
        
        super.init()
        
        // Initialization will fail if the name or option properties are empty strings
        if name.isEmpty || option.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(owner, forKey: PropertyKey.ownerKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeObject(option, forKey: PropertyKey.optionKey)
        aCoder.encodeObject(size, forKey: PropertyKey.sizeKey)
        aCoder.encodeObject(status, forKey:PropertyKey.statusKey)
        aCoder.encodeObject(time, forKey: PropertyKey.timeKey)
    }
    
    // Initialization for loading previously saved/encoded data
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let owner = aDecoder.decodeObjectForKey(PropertyKey.ownerKey) as! String
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        let option = aDecoder.decodeObjectForKey(PropertyKey.optionKey) as! String
        let size = aDecoder.decodeObjectForKey(PropertyKey.sizeKey) as! Int
        let status = aDecoder.decodeObjectForKey(PropertyKey.statusKey) as! String
        let time = aDecoder.decodeObjectForKey(PropertyKey.timeKey) as! String
        
        // Must call the designated initializer for this class
        self.init(name: name, owner: owner, photo: photo, option: option, size: size, status: status, time: time)
    }
    
}
