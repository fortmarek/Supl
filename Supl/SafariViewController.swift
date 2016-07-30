//
//  SafariViewController.swift
//  Supl
//
//  Created by Marek Fořt on 16.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class SafariViewController: UIViewController {

    @IBOutlet weak var openSafariButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        openSafariButton.backgroundColor = UIColor.clearColor()
        openSafariButton.layer.cornerRadius = 25
        openSafariButton.layer.borderWidth = 1
        openSafariButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        let heightPageVC = CGFloat(55) //55 is height of PageVC elements
        var bottomOfButton = openSafariButton.frame.origin.y + openSafariButton.frame.height
        while self.view.frame.size.height - bottomOfButton < heightPageVC {
            bottomOfButton -= heightConstraint.constant * 0.3 
            heightConstraint.constant = heightConstraint.constant * 0.7
            widthConstraint.constant = widthConstraint.constant * 0.7
        }
        
        
        
 

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openSafariButtonTapped(sender: UIButton) {
        let safariUrl = NSURL(string:"http://old.gjk.cz/suplovani.php")
        if let url = safariUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }


}
