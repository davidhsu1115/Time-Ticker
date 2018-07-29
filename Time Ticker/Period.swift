//
//  Period.swift
//  Time Ticker
//
//  Created by fangwiehsu on 2018/7/28.
//  Copyright © 2018年 fangwiehsu. All rights reserved.
//

import Foundation
import Cocoa

extension Period {
    
    func currentlyString() -> String {
        
        if let inDate = self.inDate{
            
            return Period.stringFromDates(date1: inDate, date2: Date())
            
        }
        
        return "ERROR 001"
    }
    
    //Let this function can be used anywhere else
    class func stringFromDates(date1: Date, date2: Date) -> String {
        
        var theString = ""
        let cal = Calendar.current.dateComponents([.hour, .minute, .second], from: date1, to: date2)
        
        guard let hour = cal.hour, let minute = cal.minute, let second = cal.second
            else{
                return "ERROR 002"
        }
        
        if hour > 0{
            theString += "\(hour)h \(minute)m "
        }else{
            
            if minute > 0{
                theString += "\(minute)m "
            }
            
        }
        theString += "\(second)s"
        
        return theString
    }
    
    func perttyDate(date: Date) -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        
        return formatter.string(from: date)
    }
    
    func perttyInDate() -> String {
        
        if let inDate = self.inDate{
            return perttyDate(date: inDate)
        }
        
        return "ERROR 003"
        
    }
    
    func perttyOutDate() -> String {
        
        if let outDate = self.outDate{
            return perttyDate(date: outDate)
        }
        
        return "ERROR 004"
        
    }
    
    func time() -> TimeInterval{
        
        if let inDate = self.inDate {
            if let outDate = self.outDate{
                
                return outDate.timeIntervalSince(inDate)
                
            }else{
                return Date().timeIntervalSince(inDate)
                
            }
        }
        
        return 0.0
        
    }
    
}
