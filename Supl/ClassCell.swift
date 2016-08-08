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
        textField.autocapitalizationType = .AllCharacters
        textForTextfield()
        
        textField.addTarget(self, action: #selector(refreshPlaceholder), forControlEvents: .EditingDidEndOnExit)
        
        segmentController.addTarget(self, action: #selector(segmentChanged(_:)), forControlEvents: .ValueChanged)
        guard let segmentIndex = defaults.valueForKey("segmentIndex") as? Int else {return}
        segmentController.selectedSegmentIndex = segmentIndex
        
    }
    
    func segmentChanged(segmentController: UISegmentedControl) {
        getPlaceholder()
        
        defaults.setInteger(segmentController.selectedSegmentIndex, forKey: "segmentIndex")
    }
    
    func refreshPlaceholder() {
        if let clas = textField.text?.replaceString([" "]) where clas == "" {
            textField.text = ""
            getPlaceholder()
        }
    }
    
    func textForTextfield() {
        //Placeholder if class is not set
        guard let classString = defaults.valueForKey("class") as? String where classString != ""
            else {
                getPlaceholder()
                return
        }
        
        
        textField.text = classString.replaceString([" "])
    }
    
    func getPlaceholder() {
        if segmentController.selectedSegmentIndex == 0 {
            textField.attributedPlaceholder = NSAttributedString(string: "R6.A")
        }
        
        else {
            textField.attributedPlaceholder = NSAttributedString(string: "Novák")
        }
    }

}
