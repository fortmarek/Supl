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
    
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textField.delegate = self
        self.selectionStyle = .none
        textField.keyboardType = .default
        textForTextfield()
        
        textField.addTarget(self, action: #selector(refreshPlaceholder), for: .editingDidEndOnExit)
        
        segmentController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        guard let segmentIndex = defaults.value(forKey: "segmentIndex") as? Int else {return}
        segmentController.selectedSegmentIndex = segmentIndex
        
        getPlaceholder()
        
    }
    
    func segmentChanged(_ segmentController: UISegmentedControl) {
        getPlaceholder()
        
        guard
            let clas = defaults.value(forKey: "class") as? String,
            let school = defaults.value(forKey: "schoolUrl") as? String
            else {
                defaults.set(segmentController.selectedSegmentIndex, forKey: "segmentIndex")
                return
        }
        let dataController = DataController()
        
        //Before setting segmentIndex delete the property and then post it again with the new segmentIndex
        
        dataController.deleteProperty(clas, school: school)
        defaults.set(segmentController.selectedSegmentIndex, forKey: "segmentIndex")
        dataController.postProperty(clas, school: school)
    }
    
    func refreshPlaceholder() {
        if let clas = textField.text?.removeExcessiveSpaces , clas == "" {
            textField.text = ""
            getPlaceholder()
        }
    }
    
    func textForTextfield() {
        //Placeholder if class is not set
        guard let classString = defaults.value(forKey: "class") as? String else {return}
        
        getPlaceholder()
        textField.text = classString.removeExcessiveSpaces
    }
    
    func getPlaceholder() {
        if segmentController.selectedSegmentIndex == 0 {
            textField.autocapitalizationType = .allCharacters
            textField.attributedPlaceholder = NSAttributedString(string: "R6.A")
        }
        
        else {
            textField.autocapitalizationType = .words
            textField.attributedPlaceholder = NSAttributedString(string: "Příjmení Jméno")
        }
    }

}
