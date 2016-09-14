//
//  notificationCell.swift
//  Supl
//
//  Created by Marek Fořt on 25.12.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit

protocol NotificationsCellDelegate {
    func presentAlert(_ title: String, message: String, url: String)
}

class NotificationCell: UITableViewCell, NotificationsDelegate, SwitchDelegate {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    var delegate: NotificationsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        cellSwitch.addTarget(self, action: #selector(NotificationCell.switchIsChanged(_:)), for: UIControlEvents.valueChanged)
        self.selectionStyle = .none
        cellSwitch.isOn = areNotificationsAllowed()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchIsChanged(_ sender: UISwitch) {
        if cellSwitch.isOn {
    
            guard
            let notificationType = UIApplication.shared.currentUserNotificationSettings
                else {return}
            
            if let askedPermission = UserDefaults.standard.value(forKey: "askedPermission") as? Bool , askedPermission == true {
                if notificationType.types == UIUserNotificationType() {
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
        let application = UIApplication.shared
        if application.isRegisteredForRemoteNotifications {
            return true
        }
        else {
            return false
        }
    }
    
    func switchOff(){
        cellSwitch.isOn = false
    }
    
    
    
    

}
