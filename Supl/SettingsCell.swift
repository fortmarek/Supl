//
//  SettingsCell.swift
//  Supl
//
//  Created by Marek Fořt on 16.11.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit
import Kanna


class SettingsCell: UITableViewCell, UITextFieldDelegate  {
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var icon: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
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
