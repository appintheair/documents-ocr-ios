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
        let range = self.rangeAt(index)
        return (source as NSString).substring(with: range).trimmingCharacters(in: CharacterSet(charactersIn: "<"))
    }
}



































