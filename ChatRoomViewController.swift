//
//  ChatRoomViewController.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-07-06.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var tblUserList: UITableView!
    
    // Stores all users on server and their relevant information
    var users = [[String: AnyObject]]()
    // Stores the current user's username
    //var username: String!
    // Stores the information(properties) of the Fyre the user is viewing
    var fyreInfo: [String] = []
    // Stores the table section titles
    let sections = ["Group Information", "Members"]

    var configurationOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Listen for userList update from the server
        SocketIOManager.sharedInstance.listenForUserListUpdate(self.title!)
        // Observe for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUserList(_:)), name: "userListUpdateNotification", object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleApplicationDidBecomeActiveNotification), name: "myAppBecameActiveNotification", object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleAppDidEnterBackgroundNotification), name: "myAppDidEnterBackgroundNotification", object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleUsernameTakenErrorNotification), name: "usernameTakenErrorNotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK {
            //configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If there is no existing user information, call the askForUsername method to ask for user login information (username)
        // A user's information is stored in the server database and will remain in the database when user quits the app
        // The user will be associated with his previous information in the server upon relaunching of the app
        
        /*if username == nil {
            askForUsername()
        }
        // Notify server that user has stopped typing
        if username != nil {
            SocketIOManager.sharedInstance.sendStopTypingMessage(username)
        }*/
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // Remove the notification observers upon exiting the view
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "idSegueJoinChat" {
                let chatViewController = segue.destinationViewController as! ChatViewController
                chatViewController.title = self.title!
                //chatViewController.username = username
            }
        }
    }
    
    /*@IBAction func unwindToChatRoom(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ChatViewController {
            SocketIOManager.sharedInstance.exitFyreWithUsername(sourceViewController.username) { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    sourceViewController.username = nil
                })
            }
            
        }
    }*/
    
    // MARK: IBAction Methods
    
    /*@IBAction func exitChat(sender: AnyObject) {
        // When the exit button is tapped, the user's information will be deleted from the server
        // User is logged out of the chat and the list of users will be removed
        // User will be prompted to enter new user information to login
        SocketIOManager.sharedInstance.exitFyreWithUsername(self.username) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.username = nil
                self.users.removeAll()
                self.tblUserList.hidden = true
                self.askForUsername()
            })
        }
    }*/
    
    
    
    // MARK: Custom Methods
    
    /*func configureNavigationBar() {
        navigationItem.title = "FyrePlace"
    }*/
    
    
    func configureTableView() {
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        //tblUserList.hidden = true
        tblUserList.tableFooterView = UIView(frame: CGRectZero)
    }
    
    /*func askForUsername() {
        // Present an alert controller that asks for user login information (username)
        let alertController = UIAlertController(title: navigationItem.title, message: "Enter Username", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Check if the text field is empty
            let textField = alertController.textFields![0]
            if textField.text?.characters.count == 0 {
                // Recursively ask for login information if none is entered by the user
                self.askForUsername()
            }
            else {
                // Call the connectToServerWithUsername method with the entered username
                self.username = textField.text
                
                SocketIOManager.sharedInstance.connectToFyreWithUsername(self.username, fyre: self.title!)
            }
        }
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }*/
    
    // Method for handling the user list update notification (sent when the userList from server changes)
    func updateUserList(notification: NSNotification) {
        // Update the userList to match the server and reload the user list table view
        if let userList = notification.object as? [[String: AnyObject]] {
            self.users = userList
            self.tblUserList.reloadData()
            self.tblUserList.hidden = false
        }
    }
    
    // Method for handling notification for the app becoming active
    /*func handleApplicationDidBecomeActiveNotification() {
        // If the user has previous user information (username), then the user's status is changes to active
        if self.username != nil {
            SocketIOManager.sharedInstance.sendUserActiveMessage(self.username, fyre: self.title!)
        }
    }*/
    
    // Method for handling notification for app terminating
    /*func handleAppDidEnterBackgroundNotification() {
        // If the user has previous user information (username), then make sure to change the user's status to idle
        if self.username != nil {
            SocketIOManager.sharedInstance.sendUserIdleMessage(self.username)
        }
    }*/
    
    // Method for handling notification for username take error
    /*func handleUsernameTakenErrorNotification() {
        // Print an error message to screen and ask for username again
        print("Username already taken")
        self.username = nil
        askForUsername()
    }*/
    
    // MARK: UITableView Delegate and Datasource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Stores number of rows in each table section
        let rowsInSectionArray: [Int] = [5, users.count]
        var rows = 0
        if section < rowsInSectionArray.count {
            rows = rowsInSectionArray[section]
        }
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the user cells
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
        
        // First section contains the group(fyre) information
        if indexPath.section == 0 {
            cell.textLabel?.text = fyreInfo[indexPath.row]
        }
        // Second section contains the list of member currently in the fyre
        else {
            cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
            cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Active" : "Idle"
            cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }

}
