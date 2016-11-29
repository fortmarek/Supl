//
//  ViewController.swift
//  Supl
//
//  Created by Marek Fořt on 11.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit
import CoreData

// TODO: When user posts a school, server has to react


class ViewController: SuplTable {
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl = refreshController
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refresh(_:)), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        //messageLabel shows up when there is no data in the table
        messageLabel.isHidden = true
        messageLabel.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: 200)
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont().getFont(20, weight: .light)
        messageLabel.numberOfLines = 2
        messageLabel.center = CGPoint(x: self.view.bounds.width * 0.5, y: self.view.bounds.height * 0.3)
        self.tableView.addSubview(messageLabel)
        
        
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = CGPoint(x: self.tableView.bounds.width * 0.5, y: self.tableView.bounds.height * 0.3)
        self.tableView.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        
        
        //Setting font for navigationBar
        let navigationFont = UIFont().getFont(20, weight: .medium)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationFont]
        
        
        //Refresh
        guard  let viewRefreshControl = self.refreshControl else {return}
        viewRefreshControl.backgroundColor = UIColor.white
        viewRefreshControl.tintColor = UIColor.lightGray
        viewRefreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(viewRefreshControl)
        
        
        dataController.delegate = self
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettingsViewController" {
            
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showSettingsViewController", sender: self)
    }
    
    //UICollectionViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return suplArray.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        
        let day = datesArray.ref(section)
        
        let leftLabel = UILabel()
        leftLabel.text = day
        leftLabel.font = UIFont().getFont(18, weight: .medium)
        leftLabel.sizeToFit()
        
        let rightLabel = UILabel()
        //rightLabel.text = week
        rightLabel.font = UIFont().getFont(16, weight: .regular)
        rightLabel.textColor = UIColor(red: 0.43, green: 0.42, blue: 0.47, alpha: 1.0)
        rightLabel.sizeToFit()
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        
        view.setConstraints(leftLabel, attribute: .left, constant: 15)
        view.setConstraints(rightLabel, attribute: .right, constant: -10)

        return view
    }
    
    
    //MARK: Fonts
    enum FontWeight {
        case light, medium, semibold, regular
    }
    
    
    
    
    
}

