//
//  Classswift
//  Supl
//
//  Created by Marek Fořt on 07/08/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textField.delegate = self
        self.selectionStyle = .None
        textField.keyboardType = .Default
        textForTextfield()
        
        textField.addTarget(self, action: #selector(refreshPlaceholder), forControlEvents: .EditingDidEndOnExit)
        
        segmentController.addTarget(self, action: #selector(segmentChanged(_:)), forControlEvents: .ValueChanged)
        guard let segmentIndex = defaults.valueForKey("segmentIndex") as? Int else {return}
        segmentController.selectedSegmentIndex = segmentIndex
        
        getPlaceholder()
        
    }
    
    func segmentChanged(segmentController: UISegmentedControl) {
        getPlaceholder()
        
        guard
            let clas = defaults.valueForKey("class") as? String,
            let school = defaults.valueForKey("schoolUrl") as? String
            else {
                defaults.setInteger(segmentController.selectedSegmentIndex, forKey: "segmentIndex")
                return
        }
        let dataController = DataController()
        
        //Before setting segmentIndex delete the property and then post it again with the new segmentIndex
        
        dataController.deleteProperty(clas, school: school)
        defaults.setInteger(segmentController.selectedSegmentIndex, forKey: "segmentIndex")
        dataController.postProperty(clas, school: school)
    }
    
    func refreshPlaceholder() {
        if let clas = textField.text?.removeExcessiveSpaces where clas == "" {
            textField.text = ""
            getPlaceholder()
        }
    }
    
    func textForTextfield() {
        //Placeholder if class is not set
        guard let classString = defaults.valueForKey("class") as? String else {return}
        
        getPlaceholder()
        textField.text = classString.removeExcessiveSpaces
    }
    
    func getPlaceholder() {
        if segmentController.selectedSegmentIndex == 0 {
            textField.autocapitalizationType = .AllCharacters
            textField.attributedPlaceholder = NSAttributedString(string: "R6.A")
        }
        
        else {
            textField.autocapitalizationType = .Words
            textField.attributedPlaceholder = NSAttributedString(string: "Příjmení Jméno")
        }
    }

}
