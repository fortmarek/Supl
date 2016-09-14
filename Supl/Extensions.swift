//
//  Extensions.swift
//  Supl
//
//  Created by Marek Fořt on 16.11.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit


extension UIFont {
    
    enum FontWeight {
        case light, medium, semibold, regular
    }
    
    fileprivate func getOldFont(_ size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .light:
            guard let font = UIFont(name: "HelveticaNeue-Thin", size: size) else {return UIFont()}
            return font
        case .medium:
            guard let font = UIFont(name: "HelveticaNeue-Light", size: size) else {return UIFont()}
            return font
        default:
            guard let font = UIFont(name: "HelveticaNeue", size: size) else {return UIFont()}
            return font
        }
    }
    
    @available(iOS 8.2, *)
    fileprivate func getNewFont (_ size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .light:
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
        case .semibold:
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
        case .regular:
            return UIFont.systemFont(ofSize: size)
        default:
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightMedium)
        }
    }
    
    func getFont(_ size: CGFloat, weight: FontWeight) -> UIFont {
        if #available (iOS 8.2, *) {
            return getNewFont(size, weight: weight)
        }
        else {
            return getOldFont(size, weight: weight)
        }
    }
    
}

extension UIView {
    
    func setConstraints(_ item: AnyObject, attribute: NSLayoutAttribute, constant: CGFloat) {
        let horizontalConstraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: constant)
        self.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(verticalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: item.frame.width)
        self.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: item.frame.height)
        self.addConstraint(heightConstraint)
    }
    
}

extension Array {
    func ref (_ i:Int) -> Element? {
        return 0 <= i && i < count ? self[i] : nil
    }
}

extension String {
    
    var removeExcessiveSpaces: String {
        let components = self.components(separatedBy: CharacterSet.whitespaces)
        let filtered = components.filter({!$0.isEmpty})
        return filtered.joined(separator: " ")
    }
    
    func replaceString (_ stringArray: [String]) -> String {
        var result = self
        for i in 0 ..< stringArray.count {
            let stringToReplace = stringArray[i]
            result = result.replacingOccurrences(of: stringToReplace, with: "")
        }
        return result
    }
    
    func compareDate () -> (date: Date?, isNotBeforeToday: Bool) {
        let comparedDate = self.stringToDate()
        let today = Date().addingTimeInterval(-60*60*24*1)
        let compare = today.compare(comparedDate)
        if compare == .orderedDescending {
            return (Date(), false)
        }
        
        //Pokud je supl z minulosti, není potřeba ho dávat do feedu
            
        else {
            return (comparedDate, true)
        }
    }
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func getDate() -> String {
        let dateCharacters = Array(self.characters)
        var stringDate = ""
        for character in dateCharacters {
            if "\(character)" == "(" {
                break
            }
            else if Int("\(character)") != nil || "\(character)" == "."  {
                stringDate.append(character)
            }
        }
        return stringDate
    }
    
    func stringToDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.date(from: self)
        guard let finalDate = date else {return Date()}
        return finalDate
    }
}

extension Date {
    
    func isBeforeToday() -> Bool {
        let today = Date().addingTimeInterval(-60*60*24*1)
        let compare = today.compare(self)
        if compare == .orderedDescending {
            return false
        }
        else {
            return true
        }
    }
    
    func daysFrom(_ date:Date) -> Int {
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components(.day, from: date, to: self, options: [])
        return myComponents.day!
    }
    
    func getDateForm() -> String {
        
        let today = Date().addingTimeInterval(-60*60*24*1)
        let result = self.daysFrom(today)
        
        //var week = ""
        
        //TODO: Sudý a lichý týden
        /*
        if let weekOpt = weekArray.ref(section) {
            week = weekOpt
         return ("Dnes", week) ...
        }
 */
        
        if result == 0 {
            return "Dnes"
        }
            
        else if result == 1 {
            return "Zítra"
        }
            
            //If the result > 5, it means that the change is more than a week away - and so there are not any duplicates of Monday etc., we must show the whole date
            
        else if result > 5 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d.M.yyyy"
            let dateString = dateFormatter.string(from: self)
            
            let weekDay = self.getWeekDay()
            
            return "\(weekDay) \(dateString)"
        }
            
            //Showing just the day eg. Monday, Tuesday...
        else {
            let weekDay = self.getWeekDay()
            return weekDay
        }
        
    }
    
    func getWeekDay() -> String {
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components(.weekday, from: self)
        guard let weekDay = myComponents.weekday else {return ""}
        
        switch weekDay {
        case 1:
            return "Neděle"
        case 2:
            return "Pondělí"
        case 3:
            return "Úterý"
        case 4:
            return "Středa"
        case 5:
            return "Čtvrtek"
        case 6:
            return "Pátek"
        case 7:
            return "Sobota"
        default:
            return ""
        }
    }
    
    func dateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.string(from: self)
        return date
    }
    
}
