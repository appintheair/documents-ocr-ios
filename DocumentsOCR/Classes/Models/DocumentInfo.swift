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

///gender
public enum Gender {
    case Male, Female, Unknown
}

/// Struct-container for recognition fields of passport machine readable code

public struct DocumentInfo {
    
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
    public let dateOfBirth: NSDate?
    
    /// Gender
    public let gender: Gender
    
    /// Expiration date of passport
    public let expirationDate: NSDate?
    
    /// Personal number (may be used by the issuing country as it desires)
    public let personalNumber: String
    
    /// Check digits (0-9, also can be "<")
    public let checkDigits: [String]
    
    private static let bundle = PodAsset.bundleForPod("DocumentsOCR")
    private static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    
    init?(recognizedText text: String) {
        
        let regex: NSRegularExpression
        
        do {
            regex = try NSRegularExpression(pattern: DocumentInfo.passportPattern, options: [])
        }
        catch {
            return nil
        }
        
        let range = NSRange(location: 0, length: text.characters.count)
        if let result = regex.firstMatchInString(text, options: [], range: range) {
            
            issuingCountryCode = result.group(atIndex: 4, fromSource: text)
            lastname = result.group(atIndex: 6, fromSource: text)
            name = result.group(atIndex: 7, fromSource: text).stringByReplacingOccurrencesOfString("<", withString: " ")
            passportNumber = result.group(atIndex: 9, fromSource: text)
            nationalityCode = result.group(atIndex: 11, fromSource: text)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: text)
            dateOfBirth = NSDate.dateFromPassportDateCode("19" + dayOfBirthCode)
            
            let genderLetter = result.group(atIndex: 17, fromSource: text)
            switch genderLetter {
            case "F":
                gender = .Female
            case "M":
                gender = .Male
            default:
                gender = .Unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: text)
            expirationDate = NSDate.dateFromPassportDateCode("20" + expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: text)
            
            checkDigits = [
                result.group(atIndex: 10, fromSource: text),
                result.group(atIndex: 16, fromSource: text),
                result.group(atIndex: 22, fromSource: text),
                result.group(atIndex: 24, fromSource: text),
                result.group(atIndex: 25, fromSource: text),
            ]
        }
        else {
            return nil
        }
    }
    
    init?(image: UIImage, tesseractDelegate: G8TesseractDelegate? = nil) {
        let path = DocumentInfo.bundle.pathForResource("eng", ofType: "traineddata")
        
        let tesseract = DocumentInfo.tesseract
        
        tesseract.delegate = tesseractDelegate!
        tesseract.image = image
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            NSLog("Recognized: \(recognizedText)")
            
            let mrCode = recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            self.init(recognizedText: mrCode)
        }
        else {
            return nil
        }
    }
    
    
    private static var tesseract: G8Tesseract = {
        let trainDataPath = DocumentInfo.bundle.pathForResource("eng", ofType: "traineddata")
        
        let cacheURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        let tessdataURL = cacheURL.URLByAppendingPathComponent("tesseract", isDirectory: true)!.URLByAppendingPathComponent("tessdata", isDirectory: true)!
        let destinationURL = tessdataURL.URLByAppendingPathComponent("eng.traineddata")!
        
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationURL.path!) {
            DocumentInfo.createTessdataFrom(trainDataPath!, toDirectoryURL: tessdataURL, withDestinationURL: destinationURL)
        }
        
        let tesseract = G8Tesseract(language: "eng", configDictionary: [:], configFileNames: [], absoluteDataPath: tessdataURL.path!, engineMode: .TesseractOnly, copyFilesFromResources: false)
        
        var whiteList = Constants.alphabet.uppercaseString
        whiteList.appendContentsOf("<>1234567890")
        tesseract.charWhitelist = whiteList
        
        tesseract.setVariableValue("FALSE", forKey: "x_ht_quality_check")
        
        return tesseract
    }()
    
    private static func createTessdataFrom(filePath: String, toDirectoryURL tessdataURL: NSURL, withDestinationURL destinationURL: NSURL) {
        do {
            let fileManager = NSFileManager.defaultManager()
            try fileManager.createDirectoryAtPath(tessdataURL.path!,
                                                  withIntermediateDirectories: true, attributes: nil)
            
            try fileManager.copyItemAtPath(filePath, toPath: destinationURL.path!)
        }
        catch let error as NSError {
            assertionFailure("There is no tessdata directory in cache (TesseractOCR traineddata). \(error.localizedDescription)")
        }
    }
}











