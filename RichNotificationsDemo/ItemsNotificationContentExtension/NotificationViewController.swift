//
//  NotificationViewController.swift
//  ItemsNotificationContentExtension
//
//  Created by Piyush Naredi on 21/02/18.
//  Copyright © 2018 Piyush Naredi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension, UITableViewDataSource, UITableViewDelegate {

//    @IBOutlet weak var titleLabel: UILabel!
    var foodItemsListArray: Array = [String]()
    
    var subTitleforFoodItems:String?
    
    @IBOutlet weak var heightConstraintTableView: NSLayoutConstraint!
    @IBOutlet weak var foodItemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.foodItemTableView.tableFooterView = UIView()
//        self.foodItemTableView.delegate = self
//        foodItemsListArray = ["dfs","fdas","dfa"]
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
//        subTitleforFoodItems = notification.request.content.subtitle
        let userInfoDict = notification.request.content.userInfo as? [String: Any]
        if let foodItems = userInfoDict!["food-items"] {
            foodItemsListArray = (foodItems as? Array)!
//            DispatchQueue.main.async {
//            heightConstraintTableView.constant = CGFloat(foodItemsListArray.count * 50 + 30)
                self.foodItemTableView.reloadData()
//            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return foodItemsListArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = foodItemsListArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clickedIndex:\(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Food Items"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "snooze" {
            let newContent = response.notification.request.content.mutableCopy() as? UNMutableNotificationContent
            newContent?.title += " Again Reminder"
            newContent?.categoryIdentifier = "foodItemCategory"
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            let request = UNNotificationRequest(identifier: "Repeat", content: newContent!, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        completion(.dismiss)
    }
}
