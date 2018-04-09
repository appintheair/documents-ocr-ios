//
//  DocumentInfo.swift
//  DocumentOCR
//
//  Created by Михаил on 05.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import TesseractOCR
import PodAsset

/// Gender enumeration
public enum Gender {
    case male, female, unknown
}

/// Class-container for recognition fields of passport machine readable code

open class DocumentInfo: NSObject {
    
    /// Issuing country or organization (ISO 3166-1 alpha-3 code with modifications)
    public let issuingCountryCode: String
    
    /// Lastname
    public let lastname: String
    
    /// Name (firstName + ...)
    public let name: String
    
    /// Passport number
    public let passportNumber: String
    
    /// Nationality (ISO 3166-1 alpha-3 code with modifications)
    public let nationalityCode: String
    
    /// Date of birth
    public let dateOfBirth: Date?
    
    /// Gender
    public let gender: Gender
    
    /// Expiration date of passport
    public let expirationDate: Date?
    
    /// Personal number (may be used by the issuing country as it desires)
    public let personalNumber: String
    
    /// Check digits (0-9, also can be "<")
    public let checkDigits: [String]
    
    let mrCode: String
    
    init?(recognizedText text: String) {
        
        let regex = try! NSRegularExpression(pattern: Utils.passportPattern, options: [])
        
        let range = NSRange(location: 0, length: text.count)
        
        if let result = regex.firstMatch(in: text, options: [], range: range) {
            
            mrCode = (text as NSString).substring(with: result.range)
            
            issuingCountryCode = result.group(atIndex: 4, fromSource: text).replaceNumbers()
            lastname = result.group(atIndex: 6, fromSource: text).replaceNumbers()
            name = result.group(atIndex: 7, fromSource: text).replacingOccurrences(of: "<", with: " ").replaceNumbers()
            passportNumber = result.group(atIndex: 9, fromSource: text)
            nationalityCode = result.group(atIndex: 11, fromSource: text).replaceNumbers()
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: text).replaceLetters()
            dateOfBirth = Date.dateFromPassportDateCode("19" + dayOfBirthCode)
            
            let genderLetter = result.group(atIndex: 17, fromSource: text)
            switch genderLetter {
            case "F":
                gender = .female
            case "M":
                gender = .male
            default:
                gender = .unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: text).replaceLetters()
            expirationDate = Date.dateFromPassportDateCode("20" + expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: text)
            
            checkDigits = [
                result.group(atIndex: 10, fromSource: text).replaceLetters(),
                result.group(atIndex: 16, fromSource: text).replaceLetters(),
                result.group(atIndex: 22, fromSource: text).replaceLetters(),
                result.group(atIndex: 24, fromSource: text).replaceLetters(),
                result.group(atIndex: 25, fromSource: text).replaceLetters()
            ]
        }
        else {
            return nil
        }
    }
    
    convenience init?(image: UIImage, tesseractDelegate: G8TesseractDelegate? = nil) {
        if let mrCode = Utils.mrCodeFrom(image: image, tesseractDelegate: tesseractDelegate) {
            NSLog("Recognized: \(mrCode)")
            self.init(recognizedText: mrCode)
        }
        else {
            self.init(recognizedText: "")
        }
    }
}




