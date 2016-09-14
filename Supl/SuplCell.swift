//
//  SuplCell.swift
//  Supl
//
//  Created by Marek Fořt on 12.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit

class SuplCell: UITableViewCell {
    
    @IBOutlet weak var hodinaLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changeImage: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var avsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
