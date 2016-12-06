//
//  SuplTable.swift
//  Supl
//
//  Created by Marek Fořt on 29/11/2016.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit


class SuplTable: UITableViewController, DataControllerDelegate {
    
    let dataController = DataController()
    
    var suplArray = [[suplStruct]]()
    var datesArray = [String]()
    var hoursArray = [[String]]()
    var weekArray = [String]()
    
    
    var refreshController = UIRefreshControl()
    let activityIndicator = UIActivityIndicatorView()
    
    
    let messageLabel = UILabel()
    var arrayOfTextFields = [String]()
    
    let defaults = UserDefaults.standard
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suplArraySection = suplArray.ref(section)
            else {return 0}
        return suplArraySection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if suplArray.isEmpty {
            return UITableViewCell()
        }
        else {
            guard let suplArray = suplArray.ref((indexPath as NSIndexPath).section)
                else {return UITableViewCell()}
            return cellsWithSuplArray(suplArray, indexPath: indexPath)
        }
    }
    
    func refresh (_ sender:AnyObject) {
        dataController.getData(completion: {})
        //refreshController.endRefreshing()
    }
    
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
        self.refreshController.endRefreshing()
    }
    
    func emptyArray() {
        self.tableView.separatorStyle = .none
        self.messageLabel.isHidden = false
        
        if defaults.bool(forKey: "isUrlRight") == true {
            messageLabel.text = "V nejbližší době nemáte žádné změny v rozvrhu"
        }
        else {
            messageLabel.text = "Neplatné url, změňte v nastavení"
        }
        
    }
    func reloadData() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    func arrayNotEmpty() {
        self.tableView.separatorStyle = .singleLine
        self.messageLabel.isHidden = true
    }
    func saveData() {
        self.suplArray = self.dataController.suplArray
        self.datesArray = self.dataController.datesArray
    }
}

