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
    
    
    
    let defaults = UserDefaults.standard
    
    var delegate: SwitchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let font = UIFont().getFont(20, weight: .medium)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        
        self.tableView.allowsSelection = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                emailButtonTapped()
            }
            else if (indexPath as NSIndexPath).row == 1 {
                startWalkthrough()
            }
                
            else {

                guard  let appStoreLink = URL(string: "https://appsto.re/cz/fuvb-.i") else {return}
                
                let myText = "Jednoduše kontroluj změny ve svém rozvrhu!"
                let myObjects = [myText, appStoreLink] as [Any]
                let activityVC = UIActivityViewController(activityItems: myObjects, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityType.addToReadingList]
                present(activityVC, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(white: 0, alpha: 0.5)
        let header = view as! UITableViewHeaderFooterView
        guard let _ = header.textLabel else {return}
        header.textLabel!.font = UIFont().getFont(14, weight: .light)
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 2 {
            let footer = view as! UITableViewHeaderFooterView
            guard let _ = footer.textLabel else {return}
            footer.textLabel!.font = UIFont().getFont(14, weight: .light)
            footer.textLabel!.textAlignment = .center
            footer.textLabel!.text = "Verze 2.2\nVytvořil Marek Fořt"
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.frame.height < 429 {
            return (tableView.frame.height - 6 * 55) / 3
        }
        else {
            return 33 
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            return 50
        }
        else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1
        case 2:
            return 3
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if (indexPath as NSIndexPath).section == 0 {
        
            switch (indexPath as NSIndexPath).row {
            case 0:
                
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "schoolCell") as? SchoolCell
                    else {return UITableViewCell()}
                cell.textField.addTarget(self, action: #selector(saveData(_:)), for: .editingDidEndOnExit)
                
                return cell
                
            default:
                
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "classCell") as? ClassCell
                    else {return UITableViewCell()}
                
                cell.textField.addTarget(self, action: #selector(saveData(_:)), for: .editingDidEndOnExit)
                
                return cell
            }
        }
            
        else if (indexPath as NSIndexPath).section == 1 {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationCell
                else {return UITableViewCell()}
            cell.delegate = self
            self.delegate = cell
            return cell
        }
        else {
            if (indexPath as NSIndexPath).row == 2 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "shareCell") as? UrlCell
                    else {return UITableViewCell()}
                return cell
            }
                
            else {
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "urlCell") as? UrlCell
                    else {return UITableViewCell()}
                
                if (indexPath as NSIndexPath).row == 1 {
                    cell.infoLabel.text = "Tutoriál"
                    return cell
                }
                    
                    
                else {
                    return cell
                }
                
            }
        }
        
    }
    
    
    func showMark(_ message: String) {
        DispatchQueue.main.async(execute: {
            SwiftSpinner.show(message, animated: false)
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
    
    func saveData(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async(execute: {
            SwiftSpinner.show("Načítaní")
        })
        
        var school = String()
        var clas = String()
        (school, clas) = getValues()
        clas = clas.removeExcessiveSpaces
        
        
        
        let dataController = DataController()
        
        if let oldSchool = defaults.string(forKey: "schoolUrl") {
            
            if oldSchool != school {
                postSchool(school, clas: clas, oldSchool: oldSchool)
            }
            else {
                if let oldClas = defaults.string(forKey: "class") {
                    if defaults.bool(forKey: "isUrlRight") == true &&
                        clas != oldClas {
                        dataController.postProperty(clas, school: school)
                        dataController.deleteProperty(oldClas, school: school)
                    }
                }
                else {
                    if defaults.bool(forKey: "isUrlRight") == true {
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
    
    func postSchool(_ school: String, clas: String, oldSchool: String) {
        let dataController = DataController()
        

        //When school changes, clas should as well (change of properties ...)
        if let oldClas = defaults.string(forKey: "class") {
            dataController.deleteProperty(oldClas, school: oldSchool)
        }
        
        dataController.postSchool(school, completion: {
            result in
            if result == "Povedlo se" {
                self.defaults.set(true, forKey: "isUrlRight")
                dataController.postProperty(clas, school: school)
            }
            else {
                self.defaults.set(false, forKey: "isUrlRight")
            }
            self.showMark(result)
        })

    }
    
    
    func presentAlert(_ title: String, message: String, url: String) {
        // Push notifications are disabled in setting by user.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Nastavení", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: url)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
        }
        
        alertController.addAction(settingsAction)
        
        
        if url.contains("prefs") == false {
            let cancelAction = UIAlertAction(title: "Zrušit", style: .default) { (_) -> Void in
                self.delegate?.switchOff()
            }
            alertController.addAction(cancelAction)
        }
        else {
            let cancelAction = UIAlertAction(title: "Zrušit", style: .default, handler: nil)
            alertController.addAction(cancelAction)
        }
        
        
        self.present(alertController, animated: true, completion: nil)
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
            
            present(mail, animated: true, completion: nil)
        }
            //TODO - handle the possibility that the user doesn't use the native mail client
        else {
            // show failure alert - open settings to enable email account
            presentAlert("Mail", message: "V nastavení účtů si zapněte 'Pošta'", url: "prefs:root=ACCOUNT_SETTINGS")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func startWalkthrough() {
        let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContainerVC")
        present(vc, animated: true, completion: nil)
    }
    
}





