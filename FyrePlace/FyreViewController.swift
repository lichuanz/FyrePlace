//
//  FyreViewController.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-05-28.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

// Protocol used for updating the fryes array in FyreCollectionViewController
protocol FyreViewControllerDelegate: class {
    func updateFyresArray (fyre: Fyre?)
}

class FyreViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var group_photoImageView: UIImageView!
    
    @IBOutlet weak var group_nameTextField: UITextField!

    @IBOutlet weak var group_optionsLabel: UILabel!
    
    @IBOutlet weak var group_optionsPickerView: UIPickerView!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    // Passed by editing an existing fyre or constructed for creating a new fyre
    // saved to array of fyres if user taps create
    var fyre: Fyre?
    
    // An empty string array to store all the options available when creating a group
    var group_optionsPickerData: [String] = [String] ()
    
    // Variable that stores the group option selected
    var selectedGroupOption: String?
    
    // Boolean variable that indicates whether the user is editing an existing fyre or creating a new fyre
    var isEditingFyre: Bool!
    
    weak var delegate: FyreViewControllerDelegate? = nil
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks
        group_nameTextField.delegate = self
        
        // Connect the data for the picker view
        group_optionsPickerView.delegate = self
        group_optionsPickerView.dataSource = self
        
        // Initialize the array for storing group options
        group_optionsPickerData = ["Invite", "Broadcast"]
        
        //Initialize the selected group option
        selectedGroupOption = group_optionsPickerData[0]
        
        // Make sure create button is disabled until user enters a valid group name
        checkValidName()
        
        // Set up views for editing an existing fyre
        if let fyre = fyre {
            isEditingFyre = true
            navigationItem.title = fyre.name
            group_nameTextField.text = fyre.name
            group_photoImageView.contentMode = .ScaleAspectFit
            // Resize and process the fyre photo
            let newImage = resizeImage(fyre.photo, newSize: group_photoImageView.frame.size)
            group_photoImageView.image = newImage
        }
        
        // Not editing existing fyre
        else {
            isEditingFyre = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        // The number of columns of data in picker view
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // The number of rows of data in picker view
        return group_optionsPickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // The data to return for the row and component (column) passed into the function
        return group_optionsPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        // Agjust the font size in picker view
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Montserrat", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = group_optionsPickerData[row]
        
        return pickerLabel!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Store the selected group option
        selectedGroupOption = group_optionsPickerData[row]
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the create button when user is editing the group name
        createButton.enabled = false
    }
    
    func checkValidName() {
        // Disable the create button if the group name is empty
        let name = group_nameTextField.text ?? ""
        createButton.enabled = !name.isEmpty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard after user taps return
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidName()
        // Update the "New Group" label to the name of the new group given by user
        navigationItem.title = textField.text
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
        group_photoImageView.contentMode = .ScaleAspectFit
        
        // Resize and process the image selected
        let newImage = resizeImage(selectedPhoto, newSize: group_photoImageView.frame.size)
        
        // Set the group_photoImageView to display the selected photo
        group_photoImageView.image = newImage
        
        // Dismiss the image picker view
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func selectGroupPhoto(sender: UITapGestureRecognizer) {
        // Hide the keyboard when user taps to select photo
        group_nameTextField.resignFirstResponder()
        
        // Create an image picker controller
        let imagePickerController = UIImagePickerController()
        
        // Allow photos to be selected from user's photo library
        imagePickerController.sourceType = .PhotoLibrary
        
        // ViewController notified when user selects photo
        imagePickerController.delegate = self
        
        // Transition to and present the image picker controller view
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(sender: UIBarButtonItem) {
        
        let name = group_nameTextField.text ?? ""
        let owner = "NOT YET IMPLEMENTED"
        let photo = group_photoImageView.image
        let option = selectedGroupOption ?? ""
        let size = 0
        let status = "Active"
        let time = String(NSDate())
        let oldFyre = fyre
        
        // Store the data to be passed to FyreTableViewController if user taps create button
        fyre = Fyre(name: name, owner: owner, photo: photo, option: option, size: size, status: status, time: time)
        
        if isEditingFyre == true {
            // Update the fyre/room that was edited on the server side
            SocketIOManager.sharedInstance.editFyre((oldFyre?.name)!, newFyreName: (fyre?.name)!, fyreOption: (fyre?.option)!)
            // Unwind segue to home page if user is editing an existing fyre
            performSegueWithIdentifier("UnwindToYourFyres", sender: sender)
        }
        else {
            // If creating a new fyre
            // Store the new fyre created into the fyres array in FyreCollectionViewController
            delegate?.updateFyresArray(fyre)
            // Create the new fyre on the server side
            SocketIOManager.sharedInstance.createFyre(name, fyreOption: option, datetime: time)
            performSegueWithIdentifier("SegueToChat", sender: sender)
        }
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueToChat" {
            let chatRoomViewController = segue.destinationViewController.childViewControllers[0] as! ChatRoomViewController
            chatRoomViewController.title = group_nameTextField.text ?? ""
            chatRoomViewController.fyreInfo = ["Owner: "+fyre!.owner, "Type: "+fyre!.option, "Size: "+String(fyre!.size), "Status: "+fyre!.status, "Date Created: "+fyre!.time]
        }
    }
    
    // Navigation action for cancel button, returns to home scene (list of user fyres)
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddFyreMode = presentingViewController is UINavigationController
        if isPresentingInAddFyreMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    // Method that allows some configuration (store data/cleanup) on the source view controller
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }*/

}

