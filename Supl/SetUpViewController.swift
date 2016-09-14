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

class SetUpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var professorStudentSegment: UISegmentedControl!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var emailButtonBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var suplLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!

    let defaults = UserDefaults.standard
    var constraint = CGFloat(0)
    var schoolOrigin = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Keyboard Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        
        //Keyboard Editing ends when tapped outside of textfield
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if let clasString = defaults.value(forKey: "class") as? String , clasString != "" {
            classTextField.text = clasString
        }
        
        if let schoolString = defaults.value(forKey: "schoolUrl") as? String , schoolString != "" {
            schoolTextField.text = schoolString
        }
        
        if let segmentIndex = defaults.value(forKey: "segmentIndex") as? Int {
            professorStudentSegment.selectedSegmentIndex = segmentIndex
        }
        
        professorStudentSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        schoolTextField.addTarget(self, action: #selector(goToNextField), for: .editingDidEndOnExit)
        classTextField.addTarget(self, action: #selector(saveData), for: .editingDidEndOnExit)
        
        getStartedButton.backgroundColor = UIColor.clear
        getStartedButton.layer.cornerRadius = 5
        getStartedButton.layer.borderWidth = 1
        getStartedButton.layer.borderColor = UIColor(hue: 0, saturation: 0, brightness: 1.0, alpha: 1.0).cgColor

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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        initTextField("http://old.gjk.cz/suplovani.php", textField: schoolTextField)
        if professorStudentSegment.selectedSegmentIndex == 0 {
            initTextField("R6.A", textField: classTextField)
            classTextField.autocapitalizationType = .allCharacters
        }
        else {
            initTextField("Příjmení jméno", textField: classTextField)
            classTextField.autocapitalizationType = .words
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedButtonTapped(_ sender: UIButton) {
        let _ = saveData()
    }
    
    func segmentChanged() {
        
        if professorStudentSegment.selectedSegmentIndex == 0 {
            initTextField("R6.A", textField: classTextField)
            classTextField.autocapitalizationType = .allCharacters
        }
        
        else {
            initTextField("Příjmení Jméno", textField: classTextField)
            classTextField.autocapitalizationType = .words
        }

    }
    
    func initTextField(_ placeholder: String, textField: UITextField) {
        //Placeholder
        let attributes = [NSForegroundColorAttributeName : UIColor(hue: 0, saturation: 0.0, brightness: 1.0, alpha: 0.6)]
        let attributedString = NSAttributedString(string: placeholder, attributes: attributes)
        textField.attributedPlaceholder = attributedString
        
        textField.borderStyle = .roundedRect
    }
    
    func saveData() -> Bool {
        DispatchQueue.main.async(execute: {
            SwiftSpinner.show("Načítání")
        })
        
        
        guard
            let school = schoolTextField.text , school != "",
            var clas = classTextField.text , clas != ""
        else {
            showMark("Vyplňte všechna pole")
            return false
        }
        
        clas = clas.removeExcessiveSpaces
        
        let dataController = DataController()
        
        if let oldSchool = defaults.string(forKey: "schoolUrl") {
            if oldSchool != school {
                postSchool(school, clas: clas, oldSchool: oldSchool)
            }
            else {
                if let oldClas = defaults.string(forKey: "class") {
                    let segmentIndex = defaults.integer(forKey: "segmentIndex")
                    if let isUrlRight = defaults.value(forKey: "isUrlRight") as? Bool , isUrlRight == true &&
                        clas != oldClas {
                        dataController.postProperty(clas, school: school)
                        dataController.deleteProperty(oldClas, school: school)
                    }
                    else if segmentIndex != professorStudentSegment.selectedSegmentIndex {
                        dataController.deleteProperty(clas, school: school)
                        self.defaults.set(professorStudentSegment.selectedSegmentIndex, forKey: "segmentIndex")
                        dataController.postProperty(clas, school: school)
                    }
                }
                else {
                    if let isUrlRight = defaults.value(forKey: "isUrlRight") as? Bool , isUrlRight == true {
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
        defaults.set(professorStudentSegment.selectedSegmentIndex, forKey: "segmentIndex")
        
        return false
    }
    
    func postSchool(_ school: String, clas: String, oldSchool: String) {
        let dataController = DataController()
        
        
        //When school changes, clas should as well (change of properties ...)
        if let oldClas = defaults.value(forKey: "class") as? String {
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
    
    func showMark(_ message: String) {
        DispatchQueue.main.async(execute: {
            SwiftSpinner.show(message, animated: false)
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                SwiftSpinner.hide()
                if message == "Povedlo se" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Navigation")
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    func keyboardNotification(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    
        let frameHeight = self.view.frame.height
        let keyboardVerticalPosition = endFrame.origin.y
        let layout = frameHeight - keyboardVerticalPosition
        
        let isKeyboardHidden = layout == 0
        emailButtonBottomLayout?.constant = isKeyboardHidden ? constraint : layout + 20
        
        if layout + 20 > schoolOrigin - 20 + constraint && isKeyboardHidden == false {
            emailButtonBottomLayout?.constant = schoolOrigin - 20 + constraint
        }
        
        UIView.animate(withDuration: TimeInterval(0), animations: { self.view.layoutIfNeeded() })
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func goToNextField() {
        classTextField.becomeFirstResponder()
    }
    
    @IBAction func emailButtonTapped(_ sender: UIButton) {
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
            
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            presentAlert()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert() {
        // Push notifications are disabled in setting by user.
        let alertController = UIAlertController(title: "Mail", message: "V nastavení účtů si zapněte 'Pošta'", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Nastavení", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: "prefs:root=ACCOUNT_SETTINGS")
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
        }
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Zrušit", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
