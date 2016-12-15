//
//  suplModel.swift
//  Supl
//
//  Created by Marek Fořt on 14.09.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import Foundation
class suplStruct: NSObject, NSCoding {
    
    var group: String?
    var hour: String?
    var change: String?
    var professorForChange: String?
    var schoolroom: String?
    var subject: String?
    var professorUsual: String?
    var avs: String?
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self.group = aDecoder.decodeObject(forKey: "group") as? String
        self.hour = aDecoder.decodeObject(forKey: "hour") as? String
        self.change = aDecoder.decodeObject(forKey: "change") as? String
        self.professorForChange = aDecoder.decodeObject(forKey: "professorForChange") as? String
        self.schoolroom = aDecoder.decodeObject(forKey: "schoolroom") as? String
        self.subject = aDecoder.decodeObject(forKey: "subject") as? String
        self.professorUsual = aDecoder.decodeObject(forKey: "professorUsual") as? String
        self.avs = aDecoder.decodeObject(forKey: "avs") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(group, forKey: "group")
        aCoder.encode(hour, forKey: "hour")
        aCoder.encode(change, forKey: "change")
        aCoder.encode(professorForChange, forKey: "professorForChange")
        aCoder.encode(schoolroom, forKey: "schoolroom")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(professorUsual, forKey: "professorUsual")
        aCoder.encode(avs, forKey: "avs")
    }
    
}

