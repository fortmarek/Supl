//
//  NotificationViewController.swift
//  Supl
//
//  Created by Marek Fořt on 14.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import Alamofire

protocol NotificationsDelegate {
    
}

class NotificationViewController: UIViewController, NotificationsDelegate {
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var iconConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationButton.backgroundColor = UIColor.clearColor()
        notificationButton.layer.cornerRadius = 25
        notificationButton.layer.borderWidth = 1
        notificationButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        let difference = notificationButton.frame.origin.y + notificationButton.frame.height - view.frame.height
        if difference > -55 {
            iconConstraint.constant += -75 - difference
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notificationButtonTapped(sender: UIButton) {
        self.registerForPushNotifications()
    }
    
}

extension NotificationsDelegate {
    func registerForPushNotifications() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "askedPermission")
        
        let application = UIApplication.sharedApplication()
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications()
        }
    }
    
    func postToken(token: String) {
        guard let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") else {return}
        
        Alamofire.request(.POST, "http://139.59.144.155/users/\(userId)/notification",
                          parameters: ["token" : token])
    }
    
    func deleteToken() {
        guard let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") else {return}
        Alamofire.request(.DELETE, "http://139.59.144.155/users/\(userId)/notification")
    }
}
