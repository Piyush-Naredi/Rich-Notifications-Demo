//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Piyush Naredi on 16/02/18.
//  Copyright © 2018 Piyush Naredi. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let urlString = request.content.userInfo["attachment"] as? String, let fileUrl = URL(string: urlString) {
                 // Modify the notification content here...
                bestAttemptContent.title = "Topic:\(bestAttemptContent.title)"
                bestAttemptContent.subtitle = "Short:\(bestAttemptContent.subtitle)"
                bestAttemptContent.body = "Description:\(bestAttemptContent.body)"
                
                URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
                    if let location = location {
                        // Move temporary file to remove .tmp extension
                            let tmpDirectory = NSTemporaryDirectory()
                        let tmpFile = "file:".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                        let tmpUrl = URL(string: tmpFile)!
                        try? FileManager.default.moveItem(at: location, to: tmpUrl)
                        // Add the attachment to the notification content
                        if let attachment = try? UNNotificationAttachment(identifier: fileUrl.lastPathComponent, url: tmpUrl) {
                            self.bestAttemptContent?.attachments = [attachment]
                        }}
                    // Serve the notification content
                    contentHandler(self.bestAttemptContent!)
                    }.resume()
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            print("Time Expired")
            contentHandler(bestAttemptContent)
        }
    }
}
