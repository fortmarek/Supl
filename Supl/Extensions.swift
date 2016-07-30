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
        case Light, Medium, Semibold, Regular
    }
    
    private func getOldFont(size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .Light:
            guard let font = UIFont(name: "HelveticaNeue-Thin", size: size) else {return UIFont()}
            return font
        case .Medium:
            guard let font = UIFont(name: "HelveticaNeue-Light", size: size) else {return UIFont()}
            return font
        default:
            guard let font = UIFont(name: "HelveticaNeue", size: size) else {return UIFont()}
            return font
        }
    }
    
    @available(iOS 8.2, *)
    private func getNewFont (size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .Light:
            return UIFont.systemFontOfSize(size, weight: UIFontWeightLight)
        case .Semibold:
            return UIFont.systemFontOfSize(size, weight: UIFontWeightSemibold)
        case .Regular:
            return UIFont.systemFontOfSize(size)
        default:
            return UIFont.systemFontOfSize(size, weight: UIFontWeightMedium)
        }
    }
    
    func getFont(size: CGFloat, weight: FontWeight) -> UIFont {
        if #available (iOS 8.2, *) {
            return getNewFont(size, weight: weight)
        }
        else {
            return getOldFont(size, weight: weight)
        }
    }
    
}

extension UIView {
    
    func setConstraints(item: AnyObject, attribute: NSLayoutAttribute, constant: CGFloat) {
        let horizontalConstraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: constant)
        self.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: item, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraint(verticalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: item.frame.width)
        self.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: item.frame.height)
        self.addConstraint(heightConstraint)
    }
    
}

extension Array {
    func ref (i:Int) -> Element? {
        return 0 <= i && i < count ? self[i] : nil
    }
}

extension String {
    
    func replaceString (stringArray: [String]) -> String {
        var result = self
        for i in 0 ..< stringArray.count {
            let stringToReplace = stringArray[i]
            result = result.stringByReplacingOccurrencesOfString(stringToReplace, withString: "")
        }
        return result
    }
    
    func compareDate () -> (date: NSDate?, isNotBeforeToday: Bool) {
        let comparedDate = self.stringToDate()
        let today = NSDate().dateByAddingTimeInterval(-60*60*24*1)
        let compare = today.compare(comparedDate)
        if compare == .OrderedDescending {
            return (NSDate(), false)
        }
        
        //Pokud je supl z minulosti, není potřeba ho dávat do feedu
            
        else {
            return (comparedDate, true)
        }
    }
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
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
    
    func stringToDate() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.dateFromString(self)
        guard let finalDate = date else {return NSDate()}
        return finalDate
    }
}

extension NSDate {
    
    func isBeforeToday() -> Bool {
        let today = NSDate().dateByAddingTimeInterval(-60*60*24*1)
        let compare = today.compare(self)
        if compare == .OrderedDescending {
            return false
        }
        else {
            return true
        }
    }
    
    func daysFrom(date:NSDate) -> Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Day, fromDate: date, toDate: self, options: [])
        return myComponents.day
    }
    
    func getDateForm() -> String {
        
        let today = NSDate().dateByAddingTimeInterval(-60*60*24*1)
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
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d.M.yyyy"
            let dateString = dateFormatter.stringFromDate(self)
            
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
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: self)
        let weekDay = myComponents.weekday
        
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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.stringFromDate(self)
        return date
    }
    
}