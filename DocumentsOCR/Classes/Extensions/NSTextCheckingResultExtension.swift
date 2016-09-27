//
//  NSTextSearchResultExtension.swift
//  PassportOCR
//
//  Created by Михаил on 06.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

extension NSTextCheckingResult {
    func group(atIndex index: Int, fromSource source: String) -> String {
        let range = self.rangeAtIndex(index)
        return (source as NSString).substringWithRange(range).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<"))
    }
}



































