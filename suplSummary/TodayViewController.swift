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
        
        self.refreshControl = refreshController
        
        dataController.delegate = self
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        } else {
            // Fallback on earlier versions
        }
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize;
        }
        else {
            guard (suplArray.count > 0) else {return}
            let height = CGFloat(suplArray[0].count * 55)
            self.preferredContentSize = CGSize(width: 0, height: height);
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        dataController.getData(completion: {
            completionHandler(NCUpdateResult.newData)
        })
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let firstDate = datesArray.ref(0) else {return 0}
        
        //if firstDate == "Dnes" {
        if firstDate == "Zítra" {
            self.reloadInputViews()
            
            return 1
        }
        else {
            return 0
        }
        
    }
    
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "suplCell") else {return UITableViewCell()}
        return cell
    }
 */
    
}
