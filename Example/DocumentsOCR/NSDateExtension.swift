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
    return formatter
}()

extension NSDate {
    static func dateFromPassportDateCode(code: String) -> NSDate? {
        let year = code[0...3]
        let month = code[4...5]
        let day = code[6...7]
        
        return simpleFormatter.dateFromString("\(year)-\(month)-\(day)")
    }
    
    var stringDate: String {
        return simpleFormatter.stringFromDate(self)
    }
}