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


class ViewController: UITableViewController, DataControllerDelegate {
    let dataController = DataController()
    
    var suplArray = [[suplStruct]]()
    var datesArray = [String]()
    var hoursArray = [[String]]()
    var weekArray = [String]()
    
    var refreshController = UIRefreshControl()
    let activityIndicator = UIActivityIndicatorView()
    
    var classNumber = ""
    var myClass = ""
    var url = ""
    
    let messageLabel = UILabel()
    var arrayOfTextFields = [String]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl = refreshController
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.refresh(_:)), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        //messageLabel shows up when there is no data in the table
        messageLabel.hidden = true
        messageLabel.frame = CGRectMake(0, 0, self.view.bounds.width * 0.9, 200)
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont().getFont(20, weight: .Light)
        messageLabel.numberOfLines = 2
        messageLabel.center = CGPointMake(self.view.bounds.width * 0.5, self.view.bounds.height * 0.3)
        self.tableView.addSubview(messageLabel)
        
        
        self.activityIndicator.frame = CGRectMake(0, 0, 100, 100)
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = CGPointMake(self.tableView.bounds.width * 0.5, self.tableView.bounds.height * 0.3)
        self.tableView.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        
        
        //Setting font for navigationBar
        let navigationFont = UIFont().getFont(20, weight: .Medium)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationFont]
        
        
        //Refresh
        guard  let viewRefreshControl = self.refreshControl else {return}
        viewRefreshControl.backgroundColor = UIColor.whiteColor()
        viewRefreshControl.tintColor = UIColor.lightGrayColor()
        viewRefreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(viewRefreshControl)
        
        dataController.delegate = self
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        dataController.getData()
        //activityIndicator.stopAnimating()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettingsViewController" {
            
        }
    }
    
    @IBAction func settingsButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showSettingsViewController", sender: self)
    }
    
    //UICollectionViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return suplArray.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        
        let day = datesArray.ref(section)
        
        let leftLabel = UILabel()
        leftLabel.text = day
        leftLabel.font = UIFont().getFont(18, weight: .Medium)
        leftLabel.sizeToFit()
        
        let rightLabel = UILabel()
        //rightLabel.text = week
        rightLabel.font = UIFont().getFont(16, weight: .Regular)
        rightLabel.textColor = UIColor(red: 0.43, green: 0.42, blue: 0.47, alpha: 1.0)
        rightLabel.sizeToFit()
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        
        view.setConstraints(leftLabel, attribute: .Left, constant: 15)
        view.setConstraints(rightLabel, attribute: .Right, constant: -10)

        return view
    }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suplArraySection = suplArray.ref(section)
            else {return 0}
        return suplArraySection.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if suplArray.isEmpty {
            return UITableViewCell()
        }
        else {
            guard let suplArray = suplArray.ref(indexPath.section)
                else {return UITableViewCell()}
            return cellsWithSuplArray(suplArray, indexPath: indexPath)
        }
    }
    
    func refresh (sender:AnyObject) {
        dataController.getData()
        //refreshController.endRefreshing()
    }
    
    //MARK: Helper Functions
    
    //MARK: Init of the cells
    
    
    
    
    //MARK: Fonts
    enum FontWeight {
        case Light, Medium, Semibold, Regular
    }
    
    //MARK: Protocol funcs
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
        self.refreshController.endRefreshing()
    }
    
    func emptyArray() {
        self.tableView.separatorStyle = .None
        self.messageLabel.hidden = false
        
        if defaults.boolForKey("isUrlRight") == true {
            messageLabel.text = "V nejbližší době nemáte žádné změny v rozvrhu"
        }
        else {
            messageLabel.text = "Neplatné url, změňte v nastavení"
        }
        
    }
    func reloadData() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    func arrayNotEmpty() {
        self.tableView.separatorStyle = .SingleLine
        self.messageLabel.hidden = true
    }
    func saveData() {
        self.suplArray = self.dataController.suplArray
        self.datesArray = self.dataController.datesArray
    }
    
    
    
    
}

