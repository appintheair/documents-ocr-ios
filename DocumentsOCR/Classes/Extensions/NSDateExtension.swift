//
//  NSDateExtension.swift
//  PassportOCR
//
//  Created by Михаил on 06.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

let simpleFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    return formatter
}()

extension Date {
    static func dateFromPassportDateCode(_ code: String) -> Date? {
        
        let year = code.substring(from: 0, to: 3)
        let month = code.substring(from: 4, to: 5)
        let day = code.substring(from: 6, to: 7)
        
        return simpleFormatter.date(from: "\(year)-\(month)-\(day)")
    }
    
    var stringDate: String {
        return simpleFormatter.string(from: self)
    }
}
