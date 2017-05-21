//
//  FriendTableViewController.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-17.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class FriendTableViewController: UITableViewController {
    
    // MARK: Properties
    // Array that stores data on all the user's friends
    var friends: [Profile] = [Profile] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Do any additional setup after loading the view
        loadFriends()
        
    }
    
    func loadFriends() {
        //***Currently loads some placeholder friends***//
        let photo_1 = UIImage(named: "geraltOfRivia")!
        let sampleFriend_1 = Profile(name: "Geralt of Rivia", photo: photo_1)!
        
        let photo_2 = UIImage(named: "ciri")!
        let sampleFriend_2 = Profile(name: "Cirilla", photo: photo_2)!
        
        let photo_3 = UIImage(named: "shani")!
        let sampleFriend_3 = Profile(name: "Shani", photo: photo_3)!
        
        friends += [sampleFriend_1, sampleFriend_2, sampleFriend_3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell", forIndexPath: indexPath) as! FriendTableViewCell

        // Configure the cell...
        let Friend = friends[indexPath.row]
        cell.friend_photoImageView.contentMode = .ScaleAspectFit
        cell.friend_nameLabel.text = Friend.name
        
        // Resize and process the photo
        let newImage = resizeImage(Friend.photo, newSize: cell.friend_photoImageView.frame.size)
        // *** Using this command because currently there is performance issue with loading images ***//
        dispatch_async(dispatch_get_main_queue(), {cell.friend_photoImageView.image = newImage})
        
        //cell.friend_photoImageView.image = Friend.photo

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
