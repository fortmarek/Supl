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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textField.delegate = self
        self.selectionStyle = .None
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        textField.keyboardType = .Default
        textField.autocapitalizationType = .AllCharacters
        
        //Placeholder if class is not set
        guard let classString = defaults.valueForKey("class") as? String
            else {
                textField.attributedPlaceholder = NSAttributedString(string: "R6.A")
                return
        }
        textField.text = classString.replaceString([" "])
        textField.attributedPlaceholder = NSAttributedString(string: "R6.A")
 
    
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
