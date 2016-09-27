//
//  Constants.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

public let DOErrorDomain = "DocumentsOCRErrorDomain"

struct NibNames {
    static let cameraOverlayViewController = "CameraOverlayViewController"
}

struct Constants {
    
    static let alphabet = Constants.getAlphabet()
    
    private static func getAlphabet() -> String {
        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        
        var result = ""
        
        for i: UInt32 in (0..<26) {
            result.append(Character(UnicodeScalar(aCode + i)))
        }
    
        return result
    }
}













