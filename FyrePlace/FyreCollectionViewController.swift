//
//  FyreCollectionViewController.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-01.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FyreCell"

class FyreCollectionViewController: UICollectionViewController, FyreViewControllerDelegate, UISearchBarDelegate {
    
    // MARK: Properties
    
    // Boolean variable to determine whether current scene is in edit mode
    var editModeEnabled = false
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    @IBOutlet var addButton: UIBarButtonItem!
   
    @IBOutlet var profileButton: UIBarButtonItem!
    
    // Fyres that the user created
    var userOwnedFyres: [Fyre] = [Fyre] ()
    
    // Fyres that the user recently visited
    var recentlyVisitedFyres: [Fyre] = [Fyre] ()
    
    // Fyres that the user saved
    var savedFyres: [Fyre] = [Fyre] ()
    
    // All fyres on the server
    var fyreList: [Fyre] = [Fyre] ()
    
    // Boolean variable that determines whether the user created fyres should be loaded 
    var loadFyreCategory = "created"
    
    // Variable to store the index of the edited fyre
    var editedFyre: Int!
    
    // Variables for search implementation
    var dataSourceForSearchResult: [Fyre]?
    var searchBarActive: Bool = false
    var didChangeScope: Bool = false
    var searchBarBoundsY: CGFloat?
    var searchBar: UISearchBar?
    var refreshControl: UIRefreshControl?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.collectionViewLayout = CustomFyreFlowLayout ()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        // Load fyres depending on whether there are previously saved fyres
        if let savedFyres = loadFyres() {
            userOwnedFyres += savedFyres
        }
        /*else {
            loadUserFyres()
        }*/
        // Initialize the array that stores fyres from search result
        dataSourceForSearchResult = [Fyre] ()
        
        // Listen for fyreList update message from server
        SocketIOManager.sharedInstance.updateFyres()
        // Observe for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFyreList), name: "fyreListUpdateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleFyreDeletedNotification), name: "fyreDeletedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleFyreEditedNotification), name: "fyreEditedNotification", object: nil)
    }
    
    /*func loadUserFyres() {
        // *** Currently loads some SAMPLE placeholder fyres and fyres that user has created
        // *** Need to implement loading of REAL fyres that user has previously created or joined online
        
        let photo_1 = UIImage(named: "geraltOfRivia")!
        let sampleFyre_1 = Fyre(name: "Geralt of Rivia", photo: photo_1, option: "Invite")!
        
        let photo_2 = UIImage(named: "ciri")!
        let sampleFyre_2 = Fyre(name: "Cirilla", photo: photo_2, option: "Invite")!
        
        let photo_3 = UIImage(named: "shani")!
        let sampleFyre_3 = Fyre(name: "Shani", photo: photo_3, option: "Broadcast")!
        
        userOwnedFyres += [sampleFyre_1, sampleFyre_2, sampleFyre_3]
    }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareUI()
    }
    
    deinit{
        self.removeObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // If the add button was tapped
        if segue.identifier == "AddItem" {
            let fyreViewController = segue.destinationViewController.childViewControllers[0] as! FyreViewController
            fyreViewController.delegate = self
        }
        
        // If the edit button was tapped
        if segue.identifier == "ShowDetail" {
            let newFyreViewController = segue.destinationViewController as! FyreViewController
            // Get the selected cell that user wants to edit
            let indexPath = (self.collectionView?.indexPathsForSelectedItems()![0])!
            editedFyre = indexPath.item
            let selectedFyre = userOwnedFyres[indexPath.item]
            newFyreViewController.fyre = selectedFyre
            
            // Reset the view
            // Deselect the selected cell
            self.collectionView?.deselectItemAtIndexPath(indexPath, animated: true)
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath)
            cell!.contentView.backgroundColor = nil
            
            // Take the collection view out of edit mode, make appropriate UI changes
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = [self.addButton, self.profileButton]
            selectButton.style = .Plain
            selectButton.title = "Select"
            editModeEnabled = false
        }
        
        // If one of the collection view cells was tapped
        if segue.identifier == "EnterChat" {
            let chatRoomViewController = segue.destinationViewController.childViewControllers[0] as! ChatRoomViewController
            let indexPath = (self.collectionView?.indexPathsForSelectedItems()![0])!
            var selectedFyre: Fyre
            if loadFyreCategory == "visited" {
                selectedFyre = recentlyVisitedFyres[indexPath.item]
            }
            else if loadFyreCategory == "saved" {
                selectedFyre = savedFyres[indexPath.item]
            }
            else if loadFyreCategory == "explore" {
                selectedFyre = fyreList[indexPath.item]
            }
            else {
                selectedFyre = userOwnedFyres[indexPath.item]
            }
            chatRoomViewController.title = selectedFyre.name
            chatRoomViewController.fyreInfo = ["Owner: "+selectedFyre.owner, "Type: "+selectedFyre.option, "Size: "+String(selectedFyre.size), "Status: "+selectedFyre.status, "Date Created: "+selectedFyre.time]
            self.collectionView?.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    
    @IBAction func unwindToYourFyres(sender: UIStoryboardSegue) {
        // If returning from the chat room scene, exit the chat room (user is no longer a member of the chat)
        if let sourceViewController = sender.sourceViewController as? ChatRoomViewController {
            SocketIOManager.sharedInstance.leaveChannel(sourceViewController.title!)
        }
        
        // If returning to this scene after editing a fyre, update the changes of the fyre to the appropriate cell
        if let sourceViewController = sender.sourceViewController as? FyreViewController, fyre = sourceViewController.fyre {
            userOwnedFyres[editedFyre] = fyre
            let indexPath = NSIndexPath(forItem: editedFyre, inSection: 0)
            collectionView?.reloadItemsAtIndexPaths([indexPath])
            
            // Save the fyres
            saveFyres()
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        // Number of items vary depending on which category of fyres to load
        if searchBarActive {
            return dataSourceForSearchResult!.count
        }
        
        if loadFyreCategory == "visited" {
            return recentlyVisitedFyres.count
        }
        else if loadFyreCategory == "saved" {
            return savedFyres.count
        }
        else if loadFyreCategory == "explore" {
            return fyreList.count
        }
        else {
            return userOwnedFyres.count
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FyreCollectionViewCell
        var tempFyre: Fyre
    
        // Configure the cell
        // Content depends on which category of fyres to load
        if searchBarActive {
            tempFyre = dataSourceForSearchResult![indexPath.row]
        }
        else {
            if loadFyreCategory == "visited" {
                tempFyre = recentlyVisitedFyres[indexPath.row]
            }
            else if loadFyreCategory == "saved" {
                tempFyre = savedFyres[indexPath.row]
            }
            else if loadFyreCategory == "explore" {
                tempFyre = fyreList[indexPath.row]
            }
            else {
                tempFyre = userOwnedFyres[indexPath.row]
            }
        }
        
        cell.group_photoImageView.contentMode = .ScaleAspectFit
        cell.group_photoImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).CGColor
        cell.group_photoImageView.layer.cornerRadius = 5.0
        cell.group_photoImageView.layer.borderWidth = 2.0
        cell.group_photoImageView.layer.masksToBounds = true
        // Resize and process the photo
        let newImage = resizeImage(tempFyre.photo, newSize: cell.group_photoImageView.frame.size)
        cell.group_photoImageView.image = newImage
        cell.group_nameLabel.text = tempFyre.name
        //cell.group_sizeLabel.text = String(tempFyre.size)
        cell.group_sizeLabel.hidden = true
        
        // Load the group option icon depending on the content of group option
        if tempFyre.option == "Invite" {
            cell.group_optionImageView.image = UIImage(named: "Private")
        }
        if tempFyre.option == "Broadcast" {
            cell.group_optionImageView.image = UIImage(named: "Public")
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // This method gives user ability to reorder cells in the collection view
        let temp = userOwnedFyres[sourceIndexPath.item]
        userOwnedFyres[sourceIndexPath.item] = userOwnedFyres[destinationIndexPath.item]
        userOwnedFyres[destinationIndexPath.item] = temp
    }
    
    // MARK: FyreViewControllerDelegate
    
    // FyreViewControllerProtocol for updating the fyres array to include the newly user created fyre
    func updateFyresArray(fyre: Fyre?) {
        //let newIndexPath = NSIndexPath(forItem: userOwnedFyres.count, inSection: 0)
        //collectionView!.insertItemsAtIndexPaths([newIndexPath])
        userOwnedFyres += [fyre!]
        self.collectionView?.reloadData()
        
        // Save the fyres
        saveFyres()
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if editModeEnabled == true && loadFyreCategory == "created" {
            // Enable the edit and delete button when user selects a cell in "created" mode
            self.navigationItem.rightBarButtonItems!.last?.enabled = true
            self.navigationItem.rightBarButtonItems!.first?.enabled = true
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if editModeEnabled == true {
            // disable the edit and delete button when the user deselects the selected cell
            self.navigationItem.rightBarButtonItems!.last?.enabled = false
            self.navigationItem.rightBarButtonItems!.first?.enabled = false
        }
        
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // Do not perform the segue to chat when user taps a cell if it is in edit mode
        if identifier == "EnterChat" {
            if editModeEnabled == true {
                return false
            }
            
            else {
                return true
            }
        }
        
        // default
        return true
    }
    
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: Actions
    
    // When the select button is tapped, change the layout of bar button items to reveal further options
    @IBAction func selectButtonTapped(sender: UIBarButtonItem) {
        
        if(editModeEnabled == false) {
            // Put the collection view in edit mode
            selectButton.title = "Done"
            self.selectButton.style = .Done
            editModeEnabled = true
            
            // Create the "edit" and "leave" bar button items and hide the "add" button
            self.navigationItem.rightBarButtonItems = nil
            
            let editBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(FyreCollectionViewController.editButtonTapped(_:)))
            editBarButtonItem.enabled = false
            
            let leaveBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Leave", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FyreCollectionViewController.leaveButtonTapped(_:)))
            leaveBarButtonItem.enabled = false

            self.navigationItem.setRightBarButtonItems([editBarButtonItem, leaveBarButtonItem], animated: true)
            
        }
        
        else {
            
            // Deselect and unhighlight the selected cell if it exists
            let selectedCell: [NSIndexPath] = (self.collectionView?.indexPathsForSelectedItems())!
            if !selectedCell.isEmpty {
                self.collectionView?.deselectItemAtIndexPath(selectedCell[0], animated: true)
            }
            
            // Take the collection view out of edit mode, make corresponding UI changes
            self.navigationItem.rightBarButtonItem = nil 
            self.navigationItem.rightBarButtonItems = [self.addButton, self.profileButton]
            selectButton.style = .Plain
            selectButton.title = "Select"
            editModeEnabled = false

        }
    }
    
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        // Perform segue to New Fyre scene when the edit button is tapped
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
    
    // *** NOTE: Currently DELETES the selected fyre ***
    @IBAction func leaveButtonTapped(sender: UIBarButtonItem) {
        let selectedCell: [NSIndexPath] = (collectionView?.indexPathsForSelectedItems())!
        let fyreName = userOwnedFyres[selectedCell[0].item].name

        self.collectionView?.deselectItemAtIndexPath(selectedCell[0], animated: true)
        
        // Remove the selected item from the userOwnedFyres array
        userOwnedFyres.removeAtIndex(selectedCell[0].item)
        // DELETE the selected fyre from the server *** This is TEMPORARY
        SocketIOManager.sharedInstance.deleteFyre(fyreName)
        
        collectionView?.deleteItemsAtIndexPaths(selectedCell)
        
        // Save the fyres
        saveFyres()
        
        self.navigationItem.rightBarButtonItems!.last?.enabled = false
        self.navigationItem.rightBarButtonItems!.first?.enabled = false
    }
    
    func refreshControlAction() {
        // Component of search implementation
        self.cancelSearching()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // stop refreshing after 2 seconds
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    // MARK: NSCoding
    
    // Method to save all fyres
    func saveFyres() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userOwnedFyres, toFile: Fyre.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save fyres...")
        }
    }
    
    // Method to load all fyres
    func loadFyres() -> [Fyre]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Fyre.ArchiveURL.path!) as? [Fyre]
    }
    
    // MARK: <UICollectionViewDelegateFlowLayout>
    
    // Leave edge inset space for the search bar
    func collectionView( collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(self.searchBar!.frame.size.height, 0, 0, 0);
    }
    
    // MARK: Search
    func filterContentForSearchText(searchText: String, scope: String) {
        if scope == "Created" {
            self.dataSourceForSearchResult = self.userOwnedFyres.filter({ (Fyre: Fyre) -> Bool in
                return Fyre.name.containsString(searchText)
            })
        }
        if scope == "Visited" {
            self.dataSourceForSearchResult = self.recentlyVisitedFyres.filter({ (Fyre: Fyre) -> Bool in
                return Fyre.name.containsString(searchText)
            })
        }
        
        if scope == "Saved" {
            self.dataSourceForSearchResult = self.savedFyres.filter({ (Fyre: Fyre) -> Bool in
                return Fyre.name.containsString(searchText)
            })
        }
        
        if scope == "Explore" {
            self.dataSourceForSearchResult = self.fyreList.filter({ (Fyre: Fyre) -> Bool in
                return Fyre.name.containsString(searchText)
            })
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // User did type something, check datasource for text that looks the same
        if searchText.characters.count > 0 {
            // Search and reload data source
            self.searchBarActive = true
            let scope = self.searchBar!.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            self.filterContentForSearchText(searchText, scope: scope)
            self.collectionView?.reloadData()
        }
        
        else {
            // If text length == 0, search bar is not active
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // Search bar becomes active when user starts typing
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // This method is being called when search button in the keyboard tapped
        // Set searchBarActive = NO
        self.searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }
    
    func cancelSearching() {
        self.searchBarActive = false
        self.searchBar!.resignFirstResponder()
        self.searchBar!.text = ""
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBarActive {
            filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        }
        
        if searchBar.scopeButtonTitles![selectedScope] == "Visited" {
            loadFyreCategory = "visited"
        }
        else if searchBar.scopeButtonTitles![selectedScope] == "Saved" {
            loadFyreCategory = "saved"
        }
        else if searchBar.scopeButtonTitles![selectedScope] == "Explore" {
            loadFyreCategory = "explore"
        }
        else {
            loadFyreCategory = "created"
            
        }
        
        self.collectionView?.reloadData()
    }
    
    // MARK: prepareVC
    func prepareUI() {
        self.addSearchBar()
        self.addRefreshControl()
    }
    
    func addSearchBar() {
        // Configure the search bar
        if self.searchBar == nil{
            self.searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
            
            self.searchBar = UISearchBar(frame: CGRectMake(0,self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
            self.searchBar!.searchBarStyle       = UISearchBarStyle.Minimal
            self.searchBar!.tintColor            = UIColor.lightGrayColor()
            self.searchBar!.barTintColor         = UIColor.whiteColor()
            self.searchBar!.delegate             = self
            self.searchBar!.placeholder          = "Search Fyres"
            self.searchBar!.showsScopeBar        = true
            self.searchBar!.scopeButtonTitles    = ["Created", "Visited", "Saved", "Explore"]
            
            self.addObservers()
        }
        
        if !self.searchBar!.isDescendantOfView(self.view) {
            self.view .addSubview(self.searchBar!)
        }
    }
    
    func addRefreshControl() {
        if (self.refreshControl == nil) {
            self.refreshControl            = UIRefreshControl()
            self.refreshControl?.tintColor = UIColor.whiteColor()
            self.refreshControl?.addTarget(self, action: #selector(FyreCollectionViewController.refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        }
        if !self.refreshControl!.isDescendantOfView(self.collectionView!) {
            self.collectionView!.addSubview(self.refreshControl!)
        }
    }
    
    func startRefreshControl() {
        if !self.refreshControl!.refreshing {
            self.refreshControl!.beginRefreshing()
        }
    }
    
    func addObservers() {
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.New,.Old], context: context)
    }
    
    func removeObservers() {
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            if keyPath! == "contentOffset" {
                if let collectionV:UICollectionView = object as? UICollectionView {
                    self.searchBar?.frame = CGRectMake (
                        self.searchBar!.frame.origin.x,
                        self.searchBarBoundsY! + ( (-1 * collectionV.contentOffset.y) - self.searchBarBoundsY!),
                        self.searchBar!.frame.size.width,
                        self.searchBar!.frame.size.height
                    )
                }
            }
    }
    
    // MARK: Custom Methods
    func updateFyreList(notification: NSNotification) {
        if let newFyreList = notification.object as? [[String: AnyObject]] {
            fyreList.removeAll()
            for i in 0 ..< newFyreList.count {
                let name = newFyreList[i]["name"] as! String
                let owner = newFyreList[i]["owner"] as! String
                let photo = UIImage(named: "defaultPhoto")
                let option = newFyreList[i]["option"] as! String
                let size = newFyreList[i]["size"] as! Int
                let status = newFyreList[i]["status"] as! String
                let time = newFyreList[i]["time"] as! String
                
                let fyre = Fyre(name: name, owner: owner, photo: photo, option: option, size: size, status: status, time: time)!
                fyreList += [fyre]
            }
        }
    }
    
    func handleFyreDeletedNotification(notification: NSNotification) {
        if let fyreName = notification.object as? String {
            for i in 0 ..< savedFyres.count {
                if savedFyres[i].name == fyreName {
                    // remove the fyre from the savedFyres array
                }
            }
            for i in 0 ..< recentlyVisitedFyres.count {
                if recentlyVisitedFyres[i].name == fyreName {
                    // remove the fyre from the recentlyVisitedFyres array
                }
            }
        }
    }
    
    func handleFyreEditedNotification(notification: NSNotification) {
        if let fyreNames = notification.object as? [String] {
            for i in 0 ..< savedFyres.count {
                if savedFyres[i].name == fyreNames[0] {
                    savedFyres[i].name = fyreNames[1]
                }
            }
            for i in 0 ..< recentlyVisitedFyres.count {
                if recentlyVisitedFyres[i].name == fyreNames[0] {
                    recentlyVisitedFyres[i].name = fyreNames[1]
                }
            }
        }
    }
    
}
