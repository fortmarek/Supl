//
//  SchoolCell.swift
//  Supl
//
//  Created by Marek Fořt on 07/08/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class SchoolCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textField.delegate = self
        self.selectionStyle = .None
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
