//
//  SetUpViewController.swift
//  Supl
//
//  Created by Marek Fořt on 16.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import SwiftSpinner
import MessageUI
import Kanna

class SetUpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var professorStudentSegment: UISegmentedControl!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var emailButtonBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var suplLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!

    let defaults = NSUserDefaults.standardUserDefaults()
    var constraint = CGFloat(0)
    var schoolOrigin = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Keyboard Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification(_:)), name:UIKeyboardWillChangeFrameNotification, object: nil)

        
        //Keyboard Editing ends when tapped outside of textfield
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if let clasString = defaults.valueForKey("class") as? String where clasString != "" {
            classTextField.text = clasString
        }
        
        if let schoolString = defaults.valueForKey("schoolUrl") as? String where schoolString != "" {
            schoolTextField.text = schoolString
        }
        
        if let segmentIndex = defaults.valueForKey("segmentIndex") as? Int {
            professorStudentSegment.selectedSegmentIndex = segmentIndex
        }
        
        professorStudentSegment.addTarget(self, action: #selector(segmentChanged), forControlEvents: .ValueChanged)
        schoolTextField.addTarget(self, action: #selector(goToNextField), forControlEvents: .EditingDidEndOnExit)
        classTextField.addTarget(self, action: #selector(saveData), forControlEvents: .EditingDidEndOnExit)
        
        getStartedButton.backgroundColor = UIColor.clearColor()
        getStartedButton.layer.cornerRadius = 5
        getStartedButton.layer.borderWidth = 1
        getStartedButton.layer.borderColor = UIColor(hue: 0, saturation: 0, brightness: 1.0, alpha: 1.0).CGColor

        let height = self.view.frame.size.height
        let yButton = emailButton.frame.origin.y
        let heightButton = emailButton.frame.height
        let yLabel = suplLabel.frame.origin.y
        
        let constraintSize = (height - (yButton - yLabel + heightButton)) / 2
        emailButtonBottomLayout.constant = constraintSize
        constraint = constraintSize
        self.view.layoutIfNeeded()
        schoolOrigin = schoolTextField.frame.origin.y
        

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        initTextField("http://old.gjk.cz/suplovani.php", textField: schoolTextField)
        if professorStudentSegment.selectedSegmentIndex == 0 {
            initTextField("R6.A", textField: classTextField)
        }
        else {
            initTextField("Novák", textField: classTextField)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedButtonTapped(sender: UIButton) {
        saveData()
    }
    
    func segmentChanged() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(professorStudentSegment.selectedSegmentIndex, forKey: "segmentIndex")
        
        if professorStudentSegment.selectedSegmentIndex == 0 {
            initTextField("R6.A", textField: classTextField)
        }
        
        else {
            initTextField("Novák", textField: classTextField)
        }

    }
    
    func initTextField(placeholder: String, textField: UITextField) {
        //Placeholder
        let attributes = [NSForegroundColorAttributeName : UIColor(hue: 0, saturation: 0.0, brightness: 1.0, alpha: 0.6)]
        let attributedString = NSAttributedString(string: placeholder, attributes: attributes)
        textField.attributedPlaceholder = attributedString
        
        textField.borderStyle = .RoundedRect
    }
    
    func saveData() -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.show("Načítání")
        })
        
        
        guard
            let school = schoolTextField.text where school != "",
            var clas = classTextField.text where clas != ""
        else {
            showMark("Vyplňte všechna pole")
            return false}
        
        clas = clas.replaceString([" "])
        
        let dataController = DataController()
        
        if let oldSchool = defaults.valueForKey("schoolUrl") as? String {
            if oldSchool != school {
                postSchool(school, clas: clas, oldSchool: oldSchool)
            }
            else {
                if let oldClas = defaults.valueForKey("class") as? String {
                    if let isUrlRight = defaults.valueForKey("isUrlRight") as? Bool where isUrlRight == true &&
                        clas != oldClas {
                        dataController.postClas(clas, school: school)
                        dataController.deleteClas(oldClas, school: school)
                    }
                }
                else {
                    if let isUrlRight = defaults.valueForKey("isUrlRight") as? Bool where isUrlRight == true {
                        dataController.postClas(clas, school: school)
                    }
                }
                
                self.showMark("Povedlo se")
            }
        }
        else {
            postSchool(school, clas: clas, oldSchool: "")
        }
        
        
        
        
        self.defaults.setValue(clas, forKey: "class")
        self.defaults.setValue(school, forKey: "schoolUrl")
        
        return false
    }
    
    func postSchool(school: String, clas: String, oldSchool: String) {
        let dataController = DataController()
        
        
        //When school changes, clas should as well (change of properties ...)
        if let oldClas = defaults.valueForKey("class") as? String {
            dataController.deleteClas(oldClas, school: oldSchool)
        }
        
        dataController.postSchool(school, completion: {
            result in
            if result == "Povedlo se" {
                self.defaults.setBool(true, forKey: "isUrlRight")
                dataController.postClas(clas, school: school)
            }
            else {
                self.defaults.setBool(false, forKey: "isUrlRight")
            }
            self.showMark(result)
        })
        
    }
    
    func showMark(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.show(message, animated: false)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                SwiftSpinner.hide()
                if message == "Povedlo se" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("Navigation")
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
        let frameHeight = self.view.frame.height
        let keyboardVerticalPosition = endFrame.origin.y
        let layout = frameHeight - keyboardVerticalPosition
        
        let isKeyboardHidden = layout == 0
        emailButtonBottomLayout?.constant = isKeyboardHidden ? constraint : layout + 20
        
        if layout + 20 > schoolOrigin - 20 + constraint && isKeyboardHidden == false {
            emailButtonBottomLayout?.constant = schoolOrigin - 20 + constraint
        }
        
        UIView.animateWithDuration(NSTimeInterval(0), animations: { self.view.layoutIfNeeded() })
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func goToNextField() {
        classTextField.becomeFirstResponder()
    }
    
    @IBAction func emailButtonTapped(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["marekfort@me.com"])
            mail.setSubject("Supl")
            guard
            let url = schoolTextField.text,
            let clas = classTextField.text
                else {
                    mail.setMessageBody("<p>Mám problémy s přihlášením, mohli byste mi pomoct?</p>", isHTML: true)
                    return
            }
            mail.setMessageBody("<p>Mám problémy s přihlášením. Zadal jsem url \(url) a třídu \(clas), ale nepodařilo se mi přihlásit.</p>", isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            presentAlert()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentAlert() {
        // Push notifications are disabled in setting by user.
        let alertController = UIAlertController(title: "Mail", message: "V nastavení účtů si zapněte 'Pošta'", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Nastavení", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: "prefs:root=ACCOUNT_SETTINGS")
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Zrušit", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
