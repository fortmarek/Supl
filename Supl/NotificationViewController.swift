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
        
        notificationButton.backgroundColor = UIColor.clear
        notificationButton.layer.cornerRadius = 25
        notificationButton.layer.borderWidth = 1
        notificationButton.layer.borderColor = UIColor.white.cgColor
        
        let difference = notificationButton.frame.origin.y + notificationButton.frame.height - view.frame.height
        if difference > -55 {
            iconConstraint.constant += -75 - difference
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        self.registerForPushNotifications()
    }
    
}

extension NotificationsDelegate {
    func registerForPushNotifications() {
        UserDefaults.standard.set(true, forKey: "askedPermission")
        
        let application = UIApplication.shared
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications()
        }
    }
    
    func postToken(_ token: String) {
        guard let userId = UserDefaults.standard.value(forKey: "userId") else {return}
        print(token)
        let _ = Alamofire.request("http://139.59.144.155/users/\(userId)/notification", method: .post,
                          parameters: ["token" : token])
    }
    
    func deleteToken() {
        guard let userId = UserDefaults.standard.value(forKey: "userId") else {return}
        let _ = Alamofire.request("http://139.59.144.155/users/\(userId)/notification", method: .delete)
    }
}
