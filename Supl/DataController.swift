//
//  DataModel.swift
//  Supl
//
//  Created by Marek Fořt on 16.11.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DataControllerDelegate {
    func stopAnimating()
    func emptyArray()
    func arrayNotEmpty()
    func reloadData()
    func saveData()
}

class DataController {
    
    var datesArray = [String]()
    var suplArray = [[suplStruct]]()
    var daysArray = [NSDate]()
    var weekArray = [String]()
    
    var delegate: DataControllerDelegate?
    let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId")

    
    
    func postSchool(school: String, completion: (result: String) -> ()) {
        
        Alamofire.request(.POST, "http://139.59.144.155/schools", parameters: ["school" : school])
            .responseJSON{ response in
                guard let resp = response.response else {return}
                if resp.statusCode == 200 {
                     completion(result: "Povedlo se")
                }
                else {
                    guard let data = response.data else {return}
                    let json = JSON(data: data)
                    let result = String(json["message"])
                    
                    completion(result: result)
                }
        }
    }
    
    func deleteProperty(property: String, school: String) {
        guard let userId = self.userId else {return}
        
        
        let segmentIndex = getSegmentIndex()
    
        if segmentIndex == 0 {
            Alamofire.request(.DELETE, "http://139.59.144.155/classes", parameters: ["school" : school, "clas" : property, "user" : userId])
        }
        
        else {
            Alamofire.request(.DELETE, "http://139.59.144.155/professors", parameters: ["school" : school, "prof" : property, "user" : userId])
        }
    }
    
    func postProperty(property: String, school: String) {
        guard let userId = self.userId else {return}
        
        let segmentIndex = getSegmentIndex()
        
        if segmentIndex == 0 {
            Alamofire.request(.POST, "http://139.59.144.155/classes", parameters: ["school" : school, "clas" : property, "user" : userId])
        }
        
        else {
            Alamofire.request(.POST, "http://139.59.144.155/professors", parameters: ["school" : school, "prof" : property, "user" : userId])
        }
    }
    
    func getSegmentIndex() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let segmentIndex = defaults.valueForKey("segmentIndex") as? Int else {
            return 0
        }
        
        return segmentIndex
    }
    
    func getData() {
        guard
            let dataDelegate = self.delegate,
            let userId = self.userId
        else {return}
        
        resetData()
        
        Alamofire.request(.GET, "http://139.59.144.155/users/\(userId)")
            .responseJSON { response in
                
                guard let data = response.data else {return}
                let json = JSON(data: data)
                self.getChanges(json)

                if self.suplArray.isEmpty {
                    dataDelegate.emptyArray()
                }
                else {
                    dataDelegate.arrayNotEmpty()
                }
                
                dataDelegate.saveData()
                dataDelegate.reloadData()
                guard let dataDelegate = self.delegate else {return}
                dataDelegate.stopAnimating()
            
        }
    }
    
    func getSupl(json: JSON) -> suplStruct {
        var supl = suplStruct()
        
        let change = getProperty(json, property: "change")
        let hour = getProperty(json, property: "hour")
        
        //If change empty, class is away from school (different layout)
        if change == "" {
            var avs = ""
            var deleteBlank = true
            for char in hour.characters {
                if char == "d" {
                    deleteBlank = false
                }
                
                if deleteBlank && char != Character(" ") && char != Character(" ") {
                    avs += ("\(char)")
                }
                
                else if deleteBlank == false {
                    avs += ("\(char)")
                }
                
            }
            supl.avs = avs
            supl.change = "AvŠ"
        }
        
        else {
            supl.change = change
            supl.hour = hour
        }
        
        supl.subject = getProperty(json, property: "subject")
        supl.group = getProperty(json, property: "group")
        supl.schoolroom = getProperty(json, property: "schoolroom")
        supl.professorForChange = getProperty(json, property: "professor_for_change")
        supl.professorUsual = getProperty(json, property: "professor_usual")

        return supl
        
    }
    
    func getChanges(json:JSON) {
        for (_, subJson) in json["clas_changes"] {
            guard let strDate = subJson["date"].string else {continue}
            let date = strDate.stringToDate()
            //TODO: Only for testing!
            //guard date.isBeforeToday() else {continue}
            
            let day = date.getDateForm()
            
            if !(datesArray.contains(day)) {
                datesArray.append(day)
                suplArray.append([])
            }
            
            //Used to insert into suplArray accordingly to date
            guard let dayIndex = datesArray.indexOf(day) else {continue}
            
            let supl = getSupl(subJson["properties"])
            suplArray[dayIndex].append(supl)
       
        }
    }
    
    func getProperty(json: JSON, property: String) -> String {
        guard let str = json[property].string else {return ""}
        return str
    }
    
    func resetData() {
        datesArray = []
        suplArray = []
    }
    
}