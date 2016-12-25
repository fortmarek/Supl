//
//  TodayViewController.swift
//  suplSummary
//
//  Created by Marek Fořt on 28/11/2016.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: SuplTable, NCWidgetProviding {
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
        self.refreshControl = refreshController
        
        dataController.delegate = self
        
        messageLabel.isHidden = true
        messageLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width - 10, height: 110)
        messageLabel.font = UIFont().getFont(20, weight: .light)
        messageLabel.textAlignment = .center
        self.tableView.addSubview(messageLabel)
        
        let openAppGesture = UITapGestureRecognizer(target: self, action:  #selector(openMain))
        tableView.addGestureRecognizer(openAppGesture)
        
        //Loading cached data from documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        let suplPath = documentsDirectory.appendingPathComponent("suplArray").path
        guard let decodedSuplArray = NSKeyedUnarchiver.unarchiveObject(withFile: suplPath) as? [[suplStruct]] else {return}
        self.suplArray = decodedSuplArray
        
        let datesPath = documentsDirectory.appendingPathComponent("datesArray").path
        guard let decodedDatesArray = NSKeyedUnarchiver.unarchiveObject(withFile: datesPath) as? [String] else {return}
        self.datesArray = decodedDatesArray
        
        reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMain() {
        guard let openUrl = NSURL(string: "Supl://") else {return}
        extensionContext?.open(openUrl as URL, completionHandler: nil)
    }
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if (activeDisplayMode == NCWidgetDisplayMode.expanded) {
            
            guard (suplArray.count > 0) else {return}
            let height = CGFloat(suplArray[0].count * 55)
            preferredContentSize = CGSize(width: maxSize.width, height: height)
            
        }
        else {
            preferredContentSize = maxSize
        }

    }
    
    override func emptyArray() {
        tableView.separatorStyle = .none
        messageLabel.isHidden = false
        
        messageLabel.text = "Žádné změny"
        
        if #available(iOSApplicationExtension 10.0, *) {
            guard let extensionContext = self.extensionContext else {return}
            if extensionContext.widgetLargestAvailableDisplayMode == NCWidgetDisplayMode.expanded {
                extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
            }
        }
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        dataController.getData(completion: {
            
            //Caching data to documents directory to avoid tableView flashing when viewDidLoad
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
            
            let suplPath = documentsDirectory.appendingPathComponent("suplArray").path
            NSKeyedArchiver.archiveRootObject(self.suplArray, toFile: suplPath)
            
            let datesPath = documentsDirectory.appendingPathComponent("datesArray").path
            NSKeyedArchiver.archiveRootObject(self.datesArray, toFile: datesPath)

            completionHandler(NCUpdateResult.newData)
        })
        
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let firstDate = datesArray.ref(0) else {return 0}
        
        if firstDate == "Dnes" {
            self.reloadInputViews()

            messageLabel.isHidden = true

            return 1
        }
        else {
            emptyArray()
            return 0
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suplArraySection = suplArray.ref(section)
            else {return 0}
        
        if suplArraySection.count > 2 {
            if #available(iOSApplicationExtension 10.0, *) {
                guard let extensionContext = self.extensionContext else {return 0}
                //Expanded mode not available, return only 2 cells, stay in compact mode
                
                if extensionContext.widgetLargestAvailableDisplayMode == NCWidgetDisplayMode.compact {
                    extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
                }
            }
        }
        return suplArraySection.count
    }
    
}
