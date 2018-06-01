//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Piyush Naredi on 16/02/18.
//  Copyright © 2018 Piyush Naredi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var imageListArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let notificationContent = notification.request.content.mutableCopy() as? UNMutableNotificationContent
        titleLabel.text = notificationContent?.title
        subTitleLabel.text = notificationContent?.subtitle
        bodyLabel.text = notificationContent?.body

        for attachment in notificationContent!.attachments {
            if (attachment.url.startAccessingSecurityScopedResource()) {
            print("Attachment URL:\(attachment.url)")
            do {
            let imageData = try Data(contentsOf: (attachment.url))
            imageView.image = UIImage(data: imageData)
            } catch let error {
                print("Error:\(error.localizedDescription)")
            }
            attachment.url.stopAccessingSecurityScopedResource()
            }
    }
}
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "like" {
            self.likeImageView.isHidden = false
            self.likeImageView.image = UIImage(named: "likeImage")
            completion(.doNotDismiss)
        } else if actionIdentifier == "snooze" {
            let newContent = response.notification.request.content.mutableCopy() as? UNMutableNotificationContent
            newContent?.title += " Again Reminder"
            newContent?.categoryIdentifier = "defaultCategory"
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
            let request = UNNotificationRequest(identifier: "Repeat1", content: newContent!, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            completion(.dismiss)
        } else if actionIdentifier == "comment" {
            commentLabel.isHidden = false
            let response = response as! UNTextInputNotificationResponse
            commentLabel.text = response.userText
            let notificationContent = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let sharedDataSession = UserDefaults(suiteName: "group.com.company.RichNotificationsDemo")
            sharedDataSession?.set(response.userText, forKey: "commentValue")
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: notificationContent)
            sharedDataSession?.set(encodedData, forKey: "notificationContent")
            completion(.dismissAndForwardAction)
        } else if actionIdentifier == "cancel" {
            completion(.dismiss)
        }
    }
}
