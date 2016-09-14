//
//  CellData.swift
//  Supl
//
//  Created by Marek Fořt on 24/08/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit


extension ViewController {
    func cellsWithSuplArray (_ array: [suplStruct], indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "suplCell") as? SuplCell,
            let suplItem = array.ref((indexPath as NSIndexPath).row),
            let change = suplItem.change
            else {return UITableViewCell()}
        
        cell.infoLabel.text = ""
        cell.avsLabel.isHidden = true
        
        setSubjectLabel(suplItem.subject, group: suplItem.group, subjectLabel: cell.subjectLabel)
        
        setInfoLabel(suplItem.schoolroom, professorForChange: suplItem.professorForChange, infoLabel: cell.infoLabel, change: change)
        
        
        
        if let hour = suplItem.hour {
            
            let fontBig = UIFont().getFont(18, weight: .medium)
            let fontSmall = UIFont().getFont(14, weight: .medium)
            let myMutableString = NSMutableAttributedString(string: hour, attributes: [NSFontAttributeName: fontBig])
            
            let location = hour.characters.count - 3
            myMutableString.addAttribute(NSFontAttributeName, value: fontSmall, range: NSRange(location: location,length:3))
            
            cell.hodinaLabel.attributedText = myMutableString
            
        }
        
        switchChange(cell, suplItem: suplItem, change: change)
        
        addGroupForProfessors(suplItem.group, subjectLabel: cell.subjectLabel)
        
        
        return cell
    }
    
    
    fileprivate func switchChange(_ cell: SuplCell, suplItem: suplStruct, change: String) {
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
            cell.avsLabel.isHidden = false
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
            
            if defaults.integer(forKey: "segmentIndex") == 0 {
                guard
                    let usualProfessor = suplItem.professorUsual else {break}
                cell.infoLabel.text = usualProfessor
            }
                
            else {
                guard let clasUsual = suplItem.professorForChange else {break}
                cell.infoLabel.text = clasUsual
            }
        }
    }
    
    fileprivate func setSubjectLabel(_ subject: String?, group: String?, subjectLabel: UILabel) {
        if let subject = subject {
            subjectLabel.text = subject
        }
        else {
            subjectLabel.text = "Třída"
        }
        
        addGroup(group, subjectLabel: subjectLabel)
    }
    
    fileprivate func addGroup(_ group: String?, subjectLabel: UILabel) {
        //Capitalize group, check it's not empty
        guard let capitalizedGroup = group?.uppercased() , group != " " && group != "" else {return}

        //Adding group in () after subject
        guard let labelText = subjectLabel.text , defaults.integer(forKey: "segmentIndex") == 0 else {return}
        subjectLabel.text = labelText + " (" + capitalizedGroup + ")"
    }
    
    fileprivate func  setInfoLabel(_ schoolroom: String?, professorForChange: String?, infoLabel: UILabel, change: String) {
        // Schoolroom is not empty and change is not změna (infoLabel then consists of schoolroom only)
        if let schoolroom = schoolroom , schoolroom != " " && change != "změna" {
            infoLabel.text = schoolroom
        }
        
        guard let professor = professorForChange , professor != " " && change != "supluje" && change != "spojí"
            else {return }
        
        if let labelText = infoLabel.text , labelText != "" {
            infoLabel.text = labelText + " · " + professor
        }
        else {
            infoLabel.text = professor
        }
        
    }
    
    fileprivate func addGroupForProfessors(_ group: String?, subjectLabel: UILabel) {
        guard
            let group = group,
            let labelText = subjectLabel.text
            , defaults.integer(forKey: "segmentIndex") == 1
            else {return}
        
        subjectLabel.text = labelText + " · " + group
        
        
    }
    
    
    
}
