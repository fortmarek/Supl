//
//  UrlCell.swift
//  Supl
//
//  Created by Marek Fořt on 25.12.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit

class UrlCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .gray
        self.isUserInteractionEnabled = true 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
