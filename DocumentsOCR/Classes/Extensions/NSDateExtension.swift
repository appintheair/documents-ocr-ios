//
//  NSDateExtension.swift
//  PassportOCR
//
//  Created by Михаил on 06.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

let simpleFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    
    return formatter
}()

extension NSDate {
    static func dateFromPassportDateCode(_ code: String) -> NSDate? {
        
        let year = code.substring(0, to: 3)
        let month = code.substring(4, to: 5)
        let day = code.substring(6, to: 7)
        
        return simpleFormatter.dateFromString("\(year)-\(month)-\(day)")
    }
    
    var stringDate: String {
        return simpleFormatter.stringFromDate(self)
    }
}
