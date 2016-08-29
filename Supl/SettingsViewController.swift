//
//  SettingsViewController.swift
//  Supl
//
//  Created by Marek Fořt on 16.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit
import SwiftSpinner
import MessageUI

protocol SwitchDelegate {
    func switchOff()
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, NotificationsCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var delegate: SwitchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let font = UIFont().getFont(20, weight: .Medium)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        
        self.tableView.allowsSelection = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        var school = String()
        var clas = String()
        (school, clas) = getValues()
        
        defaults.setValue(clas, forKey: "class")
        
        let dataController = DataController()
        dataController.postSchool(school, completion: {
            result in
            if result == "Povedlo se" {
                self.defaults.setValue(school, forKey: "schoolUrl")
            }
        })
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                emailButtonTapped()
            }
            else if indexPath.row == 1 {
                startWalkthrough()
            }
                
            else {

                guard  let appStoreLink = NSURL(string: "https://appsto.re/cz/fuvb-.i") else {return}
                
                let myText = "Jednoduše kontroluj změny ve svém rozvrhu!"
                let myObjects = [myText, appStoreLink]
                let activityVC = UIActivityViewController(activityItems: myObjects, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityTypeAddToReadingList]
                presentViewController(activityVC, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(white: 0, alpha: 0.5)
        let header = view as! UITableViewHeaderFooterView
        guard let _ = header.textLabel else {return}
        header.textLabel!.font = UIFont().getFont(14, weight: .Light)
        
        if section == 0 {
            header.textLabel!.text = "Uživatel"
        }
        else if section == 1 {
            header.textLabel!.text = "Oznámení"
        }
        else {
            header.textLabel!.text = "Ostatní"
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 2 {
            let footer = view as! UITableViewHeaderFooterView
            guard let _ = footer.textLabel else {return}
            footer.textLabel!.font = UIFont().getFont(14, weight: .Light)
            footer.textLabel!.textAlignment = .Center
            footer.textLabel!.text = "Verze 2.1.1\nVytvořil Marek Fořt"
        }
        
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.frame.height < 429 {
            return (tableView.frame.height - 6 * 55) / 3
        }
        else {
            return 33 
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            return 50
        }
        else {
            return 0
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1
        case 2:
            return 3
        default:
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
        
            switch indexPath.row {
            case 0:
                
                guard let cell = self.tableView.dequeueReusableCellWithIdentifier("schoolCell") as? SchoolCell
                    else {return UITableViewCell()}
                cell.textField.addTarget(self, action: #selector(saveData(_:)), forControlEvents: .EditingDidEndOnExit)
                
                return cell
                
            default:
                
                guard let cell = self.tableView.dequeueReusableCellWithIdentifier("classCell") as? ClassCell
                    else {return UITableViewCell()}
                
                cell.textField.addTarget(self, action: #selector(saveData(_:)), forControlEvents: .EditingDidEndOnExit)
                
                return cell
            }
        }
            
        else if indexPath.section == 1 {
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier("notificationCell") as? NotificationCell
                else {return UITableViewCell()}
            cell.delegate = self
            self.delegate = cell
            return cell
        }
        else {
            if indexPath.row == 2 {
                guard let cell = tableView.dequeueReusableCellWithIdentifier("shareCell") as? UrlCell
                    else {return UITableViewCell()}
                return cell
            }
                
            else {
                guard let cell = self.tableView.dequeueReusableCellWithIdentifier("urlCell") as? UrlCell
                    else {return UITableViewCell()}
                
                if indexPath.row == 1 {
                    cell.infoLabel.text = "Tutoriál"
                    return cell
                }
                    
                    
                else {
                    return cell
                }
                
            }
        }
        
    }
    
    
    func showMark(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.show(message, animated: false)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                SwiftSpinner.hide()
            }
            
        })
    }
    
    func getValues() -> (String, String) {
        guard
            let schoolCell = tableView.visibleCells[0] as? SchoolCell,
            let clasCell = tableView.visibleCells[1] as? ClassCell,
            let school = schoolCell.textField.text,
            let clas = clasCell.textField.text
        else {return ("", "")}
        
        return (school, clas)
    }
    
    func saveData(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.show("Načítání")
        })
        
        var school = String()
        var clas = String()
        (school, clas) = getValues()
        clas = clas.removeExcessiveSpaces
        
        
        
        let dataController = DataController()
        
        if let oldSchool = defaults.stringForKey("schoolUrl") {
            
            if oldSchool != school {
                postSchool(school, clas: clas, oldSchool: oldSchool)
            }
            else {
                if let oldClas = defaults.stringForKey("class") {
                    if defaults.boolForKey("isUrlRight") == true &&
                        clas != oldClas {
                        dataController.postProperty(clas, school: school)
                        dataController.deleteProperty(oldClas, school: school)
                    }
                }
                else {
                    if defaults.boolForKey("isUrlRight") == true {
                        dataController.postProperty(clas, school: school)
                    }
                }
                
                self.showMark("Povedlo se")
            }
        }
        
        else {
            postSchool(school, clas: clas, oldSchool: "")
        }
        
        
        
        
        defaults.setValue(clas, forKey: "class")
        defaults.setValue(school, forKey: "schoolUrl")
        
        textField.endEditing(true)
        return false
    }
    
    func postSchool(school: String, clas: String, oldSchool: String) {
        let dataController = DataController()
        

        //When school changes, clas should as well (change of properties ...)
        if let oldClas = defaults.stringForKey("class") {
            dataController.deleteProperty(oldClas, school: oldSchool)
        }
        
        dataController.postSchool(school, completion: {
            result in
            if result == "Povedlo se" {
                self.defaults.setBool(true, forKey: "isUrlRight")
                dataController.postProperty(clas, school: school)
            }
            else {
                self.defaults.setBool(false, forKey: "isUrlRight")
            }
            self.showMark(result)
        })

    }
    
    
    func presentAlert(title: String, message: String, url: String) {
        // Push notifications are disabled in setting by user.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Nastavení", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: url)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        alertController.addAction(settingsAction)
        
        
        if url.contains("prefs") == false {
            let cancelAction = UIAlertAction(title: "Zrušit", style: .Default) { (_) -> Void in
                self.delegate?.switchOff()
            }
            alertController.addAction(cancelAction)
        }
        else {
            let cancelAction = UIAlertAction(title: "Zrušit", style: .Default, handler: nil)
            alertController.addAction(cancelAction)
        }
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func emailButtonTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["marekfort@me.com"])
            mail.setSubject("Supl")
            
            guard
                let schoolCell = tableView.visibleCells.ref(0) as? SchoolCell,
                let classCell = tableView.visibleCells.ref(1) as? ClassCell,
                let school = schoolCell.textField.text,
                let clas = classCell.textField.text
                else {
                    mail.setMessageBody("<p>Mám problémy s přihlášením, mohli byste mi pomoct?</p>", isHTML: true)
                    return
            }
            
            mail.setMessageBody("<p>Mám problémy s přihlášením. Zadal jsem url \(school) a třídu \(clas), ale nepodařilo se mi přihlásit.</p>", isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        }
            //TODO - handle the possibility that the user doesn't use the native mail client
        else {
            // show failure alert - open settings to enable email account
            presentAlert("Mail", message: "V nastavení účtů si zapněte 'Pošta'", url: "prefs:root=ACCOUNT_SETTINGS")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startWalkthrough() {
        let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ContainerVC")
        presentViewController(vc, animated: true, completion: nil)
    }
    
}





