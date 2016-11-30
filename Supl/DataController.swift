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
    var daysArray = [Date]()
    var weekArray = [String]()
    
    var delegate: DataControllerDelegate?
    let userId = UserDefaults.standard.value(forKey: "userId")

    
    
    func postSchool(_ school: String, completion: @escaping (_ result: String) -> ()) {
        
        Alamofire.request("http://139.59.144.155/schools", method: .post, parameters: ["school" : school])
            .responseJSON{ response in
                guard let resp = response.response else {return}
                if resp.statusCode == 200 {
                     completion("Povedlo se")
                }
                else {
                    guard let data = response.data else {return}
                    let json = JSON(data: data)
                    let result = String(describing: json["message"])
                    
                    completion(result)
                }
        }
    }
    
    func deleteProperty(_ property: String, school: String) {
        guard let userId = self.userId else {return}
        
        
        let segmentIndex = getSegmentIndex()
    
        if segmentIndex == 0 {
            let _ = Alamofire.request("http://139.59.144.155/classes", method: .delete, parameters: ["school" : school, "clas" : property, "user" : userId])
            
        }
        
        else {
            let _ = Alamofire.request("http://139.59.144.155/professors", method: .delete, parameters: ["school" : school, "prof" : property, "user" : userId])
        }
    }
    
    func postProperty(_ property: String, school: String) {
        guard let userId = self.userId else {return}
        
        let segmentIndex = getSegmentIndex()
        
        if segmentIndex == 0 {
            let _ = Alamofire.request("http://139.59.144.155/classes", method: .post, parameters: ["school" : school, "clas" : property, "user" : userId])
        }
        
        else {
            let _ = Alamofire.request("http://139.59.144.155/professors", method: .post, parameters: ["school" : school, "prof" : property, "user" : userId])
        }
    }
    
    func getSegmentIndex() -> Int {
        let defaults = UserDefaults.standard
        guard let segmentIndex = defaults.value(forKey: "segmentIndex") as? Int else {
            return 0
        }
        
        return segmentIndex
    }
    
    func getData() {
        
        guard
            let dataDelegate = self.delegate,
            let sharedDefaults = UserDefaults(suiteName: "group.com.sharedDefaults"),
            let userId = sharedDefaults.string(forKey: "userId")
        else {return}
        
        resetData()
        
        Alamofire.request("http://139.59.144.155/users/\(userId)")
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
    
    func getSupl(_ json: JSON) -> suplStruct {
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
    
    func getChanges(_ json:JSON) {
        
        let segmentIndex = getSegmentIndex()
        
        var userJson = json
        
        if segmentIndex == 0 {
            userJson = userJson["clas_changes"]
        }
        else {
            userJson = userJson["prof_changes"]
        }

        
        for (_, subJson) in userJson {
            guard let strDate = subJson["date"].string else {continue}
            let date = strDate.stringToDate()
            //Only for testing!
            //guard date.isBeforeToday() else {continue}
            
            let day = date.getDateForm()
            
            if !(datesArray.contains(day)) {
                datesArray.append(day)
                suplArray.append([])
            }
            
            //Used to insert into suplArray accordingly to date
            guard let dayIndex = datesArray.index(of: day) else {continue}
            
            let supl = getSupl(subJson["properties"])
            suplArray[dayIndex].append(supl)
       
        }
    }
    
    func getProperty(_ json: JSON, property: String) -> String {
        guard let str = json[property].string else {return ""}
        return str
    }
    
    func resetData() {
        datesArray = []
        suplArray = []
    }
    
}
