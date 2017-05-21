//
//  SocketIOManager.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-07-06.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    
    // MARK: Properties
    
    // Singleton pattern: to make the content of this class accessible anywhere
    static let sharedInstance = SocketIOManager()
    // Basic class of Socket.IO for sending and receiving messages from the server
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "https://fyreplace.herokuapp.com")!)
    
    override init() {
        super.init()
    }
    
    // MARK: Methods
    
    // Connect the app to the server
    func establishConnection() {
        socket.connect()
    }
    
    // Disconnect the app to the server
    func closeConnection() {
        socket.disconnect()
    }
    
    // Listen for updated user list from the server
    func listenForUserListUpdate(fyreName: String) {
        // Send message to serrver asking for updated user list of specified fyre
        socket.emit("updateUserList", fyreName)
        // Listen for updated user list from the server
        socket.on("userList") { (dataArray, ack) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userListUpdateNotification", object: dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    // Leave the channel named fyreName on the server
    func leaveChannel(fyreName: String) {
        socket.emit("leaveFyreName", fyreName)
    }
    
    // Communicate user information with the server
    func connectToFyreWithUsername(username: String, fyre: String) {
        // Send the username
        socket.emit("connectUser", username, fyre)
        // Listen for updated user list from the server
        socket.on("userList") { (dataArray, ack) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userListUpdateNotification", object: dataArray[0] as! [[String: AnyObject]])
        }
        socket.on("usernameTakenError") { (dataArray, ack) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("usernameTakenErrorNotification", object: nil)
        }
        
        // Listen for other server messages (user joining, exiting chat, typing etc)
        listenForOtherMessages()
    }
    
    // Exit the chat using the current username, deletes the user from the server database
    func exitFyreWithUsername(username: String, completionHandler: () -> Void) {
        socket.emit("exitUser", username)
        completionHandler()
    }
    
    // Change the user connection status to idle
    func sendUserIdleMessage(username: String) {
        socket.emit("idleUser", username)
    }
    
    // Change the user connection status to active
    func sendUserActiveMessage(username: String, fyre: String) {
        socket.emit("activeUser", username, fyre)
    }
    
    // Send a message
    func sendMessage(message: String, username: String) {
        socket.emit("chatMessage", username, message)
    }
    
    // receive a message
    func receiveMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        // listen for new chat messages sent by other users
        socket.on("newChatMessage") { (dataArray, ack) -> Void in
            // Each message recieved must contain 3 key information: user who sent the message, the content of message, and the date/time sent
            var messageDictionary = [String: AnyObject] ()
            messageDictionary["username"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    
    private func listenForOtherMessages() {
        // Listen for message emitted when a new user connects to chat
        socket.on("userConnectUpdate") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("userConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        // Listen for message emitted when a user exits chat (or terminates app)
        socket.on("userExitUpdate") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("userDisconnectedNotification", object: dataArray[0] as? String)
        }
        // Listen for message emitted when a user in the chat is typing or has stopped typing
        socket.on("userTypingUpdate") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: dataArray[0] as? [String: AnyObject])
        }
    }
    
    // Send message indicating a user has started typing
    func sendStartTypingMessage(username: String) {
        socket.emit("startType", username)
    }
    
    // Send message indicating a user has stopped typing
    func sendStopTypingMessage(username: String) {
        socket.emit("stopType", username)
    }
    
    // Creating a new fyre as a new room on the server side
    func createFyre(fyre: String, fyreOption: String, datetime: String) {
        socket.emit("createFyre", fyre, fyreOption, datetime)
    }
    
    // Deleting a fyre/room on the server side
    func deleteFyre(fyre: String) {
        socket.emit("deleteFyre", fyre)
    }
    
    // Editing an existing fyre/room on the server side
    func editFyre(fyre: String, newFyreName: String, fyreOption: String) {
        socket.emit("editFyre", fyre, newFyreName, fyreOption)
    }
    
    // Listen for messages emitted from server related to updating of fyres
    func updateFyres() {
        // Listen for message emitted from server when fyreList (list of all fyres) changes
        socket.on("fyreList") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("fyreListUpdateNotification", object: dataArray[0] as! [[String: AnyObject]])
        }
        // Listen for message emitted from server when a fyre is deleted (affects savedFyres and recentlyVisitedFyres)
        socket.on("fyreDeleted") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("fyreDeletedNotification", object: dataArray[0] as! String)
        }
        // Listen for message mitted from the server when a fyre is edited (affects savedFyres and recentlyVisitedFyres)
        socket.on("fyreEdited") { (dataArray, ack) -> Void in
            // Post a notification representing event
            NSNotificationCenter.defaultCenter().postNotificationName("fyreEditedNotification", object: dataArray as! [String])
        }
    }
    
}
