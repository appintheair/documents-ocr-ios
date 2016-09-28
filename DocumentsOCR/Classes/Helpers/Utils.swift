//
//  Utils.swift
//  PassportOCR
//
//  Created by Михаил on 15.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

open class Utils {
    open static func stringFromTxtFile(_ fileName: String, inBundle bundle: Bundle = Bundle.main) -> String? {
        let filePath = bundle.path(forResource: fileName, ofType: "txt")
        let contentData = FileManager.default.contents(atPath: filePath!)
        return NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
    }
}
