//
//  Constants.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation



public struct DOErrorCodes {
    public static let recognize = 0
    public static let noCamera = 1
}

struct NibNames {
    static let cameraOverlayViewController = "CameraOverlayViewController"
}

public struct DOConstants {
    public static let errorDomain = "DocumentsOCRErrorDomain"
    
    static let alphabet: String = {
        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        
        var result = ""
        
        for i: UInt32 in (0 ..< 26) {
            result.append(Character(UnicodeScalar(aCode + i)))
        }
        
        return result
    }()
}













