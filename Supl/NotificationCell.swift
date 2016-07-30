//
//  notificationCell.swift
//  Supl
//
//  Created by Marek Fořt on 25.12.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit

protocol NotificationsCellDelegate {
    func presentAlert(title: String, message: String, url: String)
}

class NotificationCell: UITableViewCell, NotificationsDelegate, SwitchDelegate {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    var delegate: NotificationsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        cellSwitch.addTarget(self, action: #selector(NotificationCell.switchIsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.selectionStyle = .None
        cellSwitch.on = areNotificationsAllowed()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchIsChanged(sender: UISwitch) {
        if cellSwitch.on {
    
            guard
            let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
                else {return}
            
            if let askedPermission = NSUserDefaults.standardUserDefaults().valueForKey("askedPermission") as? Bool where askedPermission == true {
                if notificationType.types == UIUserNotificationType.None {
                    delegate?.presentAlert("Oznámení", message: "Oznámení musíte zapnout v nastavení", url: UIApplicationOpenSettingsURLString)
                }
            }
            self.registerForPushNotifications()
        }
            
        else {
            self.deleteToken()
        }
    }
    
    func areNotificationsAllowed() -> Bool {
        let application = UIApplication.sharedApplication()
        if application.isRegisteredForRemoteNotifications() {
            return true
        }
        else {
            return false
        }
    }
    
    func switchOff(){
        cellSwitch.on = false
    }
    
    
    
    

}
