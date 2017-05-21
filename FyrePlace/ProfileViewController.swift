//
//  ProfileViewController.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-17.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var profile_photoImageView: UIImageView!
    
    @IBOutlet weak var friendListButton: UIButton!

    @IBOutlet weak var notificationsButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    // User profile
    var userProfile = Profile(name: "Name", photo: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendListButton.setImage(UIImage(named: "FriendsSelected"), forState: .Highlighted)
        notificationsButton.setImage(UIImage(named: "NotificationsSelected"), forState: .Highlighted)
        settingsButton.setImage(UIImage(named: "SettingsSelected"), forState: .Highlighted)
        
        // If there was previously saved user profile information, load the appropriate information to view
        if let savedUserProfile = loadUserProfile() {
            profile_photoImageView.contentMode = .ScaleAspectFit
            let newImage = resizeImage(savedUserProfile.photo, newSize: profile_photoImageView.frame.size)
            profile_photoImageView.image = newImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the image picker view if the user taps cancel
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Use the info dictionary to access the original version of the selected photo
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Prevent image stretching
        profile_photoImageView.contentMode = .ScaleAspectFit
        
        // Resize and process the image selected
        let newImage = resizeImage(selectedPhoto, newSize: profile_photoImageView.frame.size)
        
        // Set the group_photoImageView to display the selected photo
        profile_photoImageView.image = newImage
        
        // Save the image to user profile
        userProfile!.photo = selectedPhoto
        saveUserProfile()
        
        // Dismiss the image picker view
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Action
    
    // Segue to friend list when corresponding UIButton is tapped
    @IBAction func segueToFriendList(sender: UIButton) {
        performSegueWithIdentifier("ShowFriendList", sender: sender)
    }
    
    
    @IBAction func selectProfilePhoto(sender: UITapGestureRecognizer) {
        
        // Create an image picker controller
        let imagePickerController = UIImagePickerController()
        
        // Allow photos to be selected from user's photo library
        imagePickerController.sourceType = .PhotoLibrary
        
        // ViewController notified when user selects photo
        imagePickerController.delegate = self
        
        // Transition to and present the image picker controller view
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // NSCoding
    func saveUserProfile() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userProfile!, toFile: Profile.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save user profile...")
        }
    }
    
    func loadUserProfile() -> Profile? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Profile.ArchiveURL.path!) as? Profile
    }
    
}
