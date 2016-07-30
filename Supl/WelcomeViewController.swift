//
//  WelcomeViewController.swift
//  Supl
//
//  Created by Marek Fořt on 19/07/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit


class WelcomeViewController: UIViewController {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var iconConstraint: NSLayoutConstraint!
    
 /*
    override func viewWillAppear(animated: Bool) {
        let height = self.view.frame.size.height - 50 //50 is height of PageVC elements
        let yIcon = abs(icon.frame.origin.y)
        let yLabel = textLabel.frame.origin.y
        textLabel.sizeToFit()
        
        let heightLabel = textLabel.frame.size.height
        let constraintSize = (height - (yLabel - yIcon + heightLabel)) / 2
        iconConstraint.constant = constraintSize
    }
    
    func setOrigin(frame: CGRect, origin: CGFloat) -> CGRect {
        return CGRect(x: frame.origin.x, y: origin, width: frame.size.width, height: frame.size.height)
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //145 is absolute value for textField and button distance in NotificationVC and height of PageVC elements
        //This way I can be sure that the button will not be out of the screen
        
        let difference = view.frame.height - textLabel.frame.origin.y - textLabel.frame.height - 145
        if difference < 0 {
            iconConstraint.constant += difference
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
