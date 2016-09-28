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
    case male, female, unknown
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
    public let dateOfBirth: Date?
    
    /// Gender
    public let gender: Gender
    
    /// Expiration date of passport
    public let expirationDate: Date?
    
    /// Personal number (may be used by the issuing country as it desires)
    public let personalNumber: String
    
    /// Check digits (0-9, also can be "<")
    public let checkDigits: [String]
    
    fileprivate static let bundle = PodAsset.bundle(forPod: "DocumentsOCR")!
    fileprivate static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    
    init?(recognizedText text: String) {
        
        let regex: NSRegularExpression
        
        do {
            regex = try NSRegularExpression(pattern: DocumentInfo.passportPattern, options: [])
        }
        catch {
            return nil
        }
        
        let range = NSRange(location: 0, length: text.characters.count)
        if let result = regex.firstMatch(in: text, options: [], range: range) {
            
            issuingCountryCode = result.group(atIndex: 4, fromSource: text)
            lastname = result.group(atIndex: 6, fromSource: text)
            name = result.group(atIndex: 7, fromSource: text).replacingOccurrences(of: "<", with: " ")
            passportNumber = result.group(atIndex: 9, fromSource: text)
            nationalityCode = result.group(atIndex: 11, fromSource: text)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: text)
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
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: text)
            expirationDate = Date.dateFromPassportDateCode("20" + expiralDateCode)
            
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
        let path = DocumentInfo.bundle.path(forResource: "eng", ofType: "traineddata")
        
        let tesseract = DocumentInfo.tesseract
        
        tesseract.delegate = tesseractDelegate!
        tesseract.image = image
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            NSLog("Recognized: \(recognizedText)")
            
            let mrCode = recognizedText.replacingOccurrences(of: " ", with: "")
            
            self.init(recognizedText: mrCode)
        }
        else {
            return nil
        }
    }
    
    
    fileprivate static var tesseract: G8Tesseract = {
        let trainDataPath = DocumentInfo.bundle.path(forResource: "eng", ofType: "traineddata")
        
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let tessdataURL = cacheURL.appendingPathComponent("tesseract", isDirectory: true).appendingPathComponent("tessdata", isDirectory: true)
        let destinationURL = tessdataURL.appendingPathComponent("eng.traineddata")
        
        if !FileManager.default.fileExists(atPath: destinationURL.path) {
            DocumentInfo.createTessdataFrom(trainDataPath!, toDirectoryURL: tessdataURL, withDestinationURL: destinationURL)
        }
        
        let tesseract = G8Tesseract(language: "eng", configDictionary: [:], configFileNames: [], absoluteDataPath: tessdataURL.path, engineMode: .tesseractOnly, copyFilesFromResources: false)
        
        var whiteList = Constants.alphabet.uppercased()
        whiteList.append("<>1234567890")
        tesseract?.charWhitelist = whiteList
        
        tesseract?.setVariableValue("FALSE", forKey: "x_ht_quality_check")
        
        return tesseract!
    }()
    
    fileprivate static func createTessdataFrom(_ filePath: String, toDirectoryURL tessdataURL: URL, withDestinationURL destinationURL: URL) {
        do {
            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: tessdataURL.path,
                                                  withIntermediateDirectories: true, attributes: nil)
            
            try fileManager.copyItem(atPath: filePath, toPath: destinationURL.path)
        }
        catch let error as NSError {
            assertionFailure("There is no tessdata directory in cache (TesseractOCR traineddata). \(error.localizedDescription)")
        }
    }
}











