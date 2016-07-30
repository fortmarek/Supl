//
//  ViewController.swift
//  Supl
//
//  Created by Marek Fořt on 11.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit
import CoreData
import Kanna

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
    
    func cellsWithSuplArray (array: [suplStruct], indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: SuplCell = tableView.dequeueReusableCellWithIdentifier("suplCell") as! SuplCell
        guard
            let suplItem = array.ref(indexPath.row),
            let change = suplItem.change
            else {
                return UITableViewCell()
        }
        
        cell.infoLabel.text = ""
        cell.avsLabel.hidden = true
        
        if let subject = suplItem.subject {
            cell.subjectLabel.text = subject
        }
        else {
            cell.subjectLabel.text = "Třída"
        }
        
        if let schoolroom = suplItem.schoolroom where schoolroom != " " && change != "změna"{
            cell.infoLabel.text = schoolroom
        }
        
        if let professor = suplItem.professorForChange where professor != " " && change != "supluje" && change != "spojí" {
            if let labelText = cell.infoLabel.text where labelText != "" {
                cell.infoLabel.text = labelText + " · " + professor
            }
            else {
                cell.infoLabel.text = professor
            }
            
        }
        
        if let group = suplItem.group where group != " " {
            var capitalizedGroup = group
            capitalizedGroup = capitalizedGroup.uppercaseString
            
            if let labelText = cell.subjectLabel.text where cell.subjectLabel.text != "" && capitalizedGroup != ""
            {
                cell.subjectLabel.text = labelText + " (" + capitalizedGroup + ")"
            }
        }
        
        //Determining the type of change - different images and other aspects for different changes
        
        switch change {
        case "supluje", "spojí":
            cell.changeImage.image = UIImage(named: "Contacts")
            cell.subjectLabel.textColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
            if let professorForChange = suplItem.professorForChange {
                cell.changeLabel.text = "\(change) \(professorForChange)"
            }
        case "přesun", "výměna":
            cell.changeImage.image = UIImage(named: "Moved")
            cell.subjectLabel.textColor = UIColor(red: 0.17, green: 0.70, blue: 0.27, alpha: 1.0)
            if let professorUsual = suplItem.professorUsual {
                cell.changeLabel.text = "\(change) \(professorUsual)"
            }
            
        case "změna":
            cell.changeImage.image = UIImage(named: "ClassShift")
            cell.subjectLabel.textColor = UIColor(red: 0.70, green: 0.23, blue: 0.92, alpha: 1.0)
            
            if let classroom = suplItem.schoolroom {
                cell.changeLabel.text = "přesun do \(classroom)"
            }
        case "AvŠ":
            guard let avs = suplItem.avs else {break}
            cell.avsLabel.text = "\(avs)"
            cell.avsLabel.hidden = false
            cell.avsLabel.textColor = UIColor(red: 0.19, green: 0.36, blue: 0.60, alpha: 1.0)
            cell.changeImage.image = UIImage(named: "AvS")
            cell.subjectLabel.text = ""
            cell.infoLabel.text = ""
            cell.changeLabel.text = ""
            cell.hodinaLabel.text = ""
        
        case "navíc":
            cell.changeImage.image = UIImage(named: "Plus")
            cell.subjectLabel.textColor = UIColor(red: 0.92, green: 0.72, blue: 0.23, alpha: 1.0)
            cell.changeLabel.text = "\(change)"
        default:
            cell.changeLabel.text = "\(change)"
            cell.subjectLabel.textColor = UIColor(red: 0.92, green: 0.28, blue: 0.23, alpha: 1.0)
            cell.changeImage.image = UIImage(named: "Cancel")
            guard
                let usualProfessor = suplItem.professorUsual else {break}
            cell.infoLabel.text = usualProfessor
            
            
        }
        
        if let hour = suplItem.hour {
            
            let fontBig = UIFont().getFont(18, weight: .Medium)
            let fontSmall = UIFont().getFont(14, weight: .Medium)
            let myMutableString = NSMutableAttributedString(string: hour, attributes: [NSFontAttributeName: fontBig])
            
            let location = hour.characters.count - 3
            myMutableString.addAttribute(NSFontAttributeName, value: fontSmall, range: NSRange(location: location,length:3))
            
            cell.hodinaLabel.attributedText = myMutableString
            
        }
        
        return cell
    }
    
    
    
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
        if let isUrlRight = defaults.valueForKey("isUrlRight") as? Bool where isUrlRight == true {
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

