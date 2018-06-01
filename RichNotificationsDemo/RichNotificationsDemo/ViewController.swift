//
//  ViewController.swift
//  RichNotificationsDemo
//
//  Created by Piyush Naredi on 16/02/18.
//  Copyright © 2018 Piyush Naredi. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var notificationContent: UNMutableNotificationContent?
    var commentText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used for showing extensio's data to viewcontroller
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showData), name: NSNotification.Name(rawValue: "ShowData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.hideData), name: NSNotification.Name(rawValue: "HideData"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showData(_ notification:Notification) {
        let dict:Dictionary<String,Any> = notification.userInfo as! Dictionary<String,Any>
        let decodedData = dict["decodedString"] as? Data
        notificationContent = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? UNMutableNotificationContent
        thanksLabel.isHidden = false
        titleLabel.isHidden = false
        subTitleLabel.isHidden = false
        descriptionLabel.isHidden = false
        commentLabel.isHidden = false
        
        titleLabel.text = notificationContent?.title
        subTitleLabel.text = notificationContent?.subtitle
        descriptionLabel.text = notificationContent?.body
        if let commentString = dict["commentValue"] as? String {
            commentLabel.text = "Comment:   \(commentString)"
        }
    }
    
    @objc func hideData(_ notification:Notification) {
        thanksLabel.isHidden = true
        titleLabel.isHidden = true
        subTitleLabel.isHidden = true
        descriptionLabel.isHidden = true
        commentLabel.isHidden = true
    }
    
    
    //schedule local notifications
    @IBAction func scheduleNotificationAction(_ sender: UIButton) {
        let content = UNMutableNotificationContent()
        content.title = "Local Notifications"
        content.subtitle =  "Good Morning"
        content.body = "While building a healthy lifestyle has been an important habit for me, I just don't have the time or the interest in joining one of those national gym chains.Instead, I have found that one of the best ways to improve and maintain my health is to simply focus on walking first thing in the morning."
        content.categoryIdentifier = "customViewCategory1"
        
        let url = Bundle.main.url(forResource: "earthgif", withExtension: "gif")
        if let urlgif = url {
        let attachment = try! UNNotificationAttachment(identifier: "gif", url: urlgif, options: [:])
        content.attachments = [attachment]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error?.localizedDescription!)
        }
    }
    
}


