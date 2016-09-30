//
//  Utils.swift
//  PassportOCR
//
//  Created by Михаил on 15.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import TesseractOCR
import PodAsset

open class Utils {

    fileprivate static let bundle = PodAsset.bundle(forPod: "DocumentsOCR")!
    static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    fileprivate static let tesseract = createTesseract()
    
    open static func stringFromTxtFile(_ fileName: String, inBundle bundle: Bundle = Bundle.main) -> String? {
        let filePath = bundle.path(forResource: fileName, ofType: "txt")
        let contentData = FileManager.default.contents(atPath: filePath!)
        return NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    static func mrCodeFrom(image: UIImage, tesseractDelegate: G8TesseractDelegate? = nil) -> String? {
        let path = bundle.path(forResource: "eng", ofType: "traineddata")
        
        tesseract.delegate = tesseractDelegate!
        tesseract.image = image
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            NSLog("Recognized: \(recognizedText)")
            
            let text = recognizedText.replacingOccurrences(of: " ", with: "")
            let regex = try? NSRegularExpression(pattern: passportPattern, options: [])
            let range = NSRange(location: 0, length: text.characters.count)
            if let result = regex!.firstMatch(in: text, options: [], range: range) {
                
                let code = (text as NSString).substring(with: result.range)
                
                return fixFirstRowIn(code: code)
            }
        }
        
        return nil
    }
    
    fileprivate static func fixFirstRowIn(code: String) -> String {
        
        let pattern = "(?<FirstLine>(?<Passport>[A-Z0-9])(?<PassportType>.)(?<IssuingCountry>[A-Z0-9]{3})(?<PassportOwner>(?<Surname>[A-Z0-9]+)<<(?<GivenName>(?:[A-Z0-9]+<)+)){1})"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: code.characters.count)
        let result = regex!.matches(in: code, options: [], range: range)
        var resultFirstRow = (code as NSString).substring(with: result[0].range)
        while resultFirstRow.characters.count != 44 {
            resultFirstRow.append("<")
        }
        
        let secondRow = code.characters.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)[1]
        
        return "\(resultFirstRow)\n\(String(secondRow))\n"
    }
    
    fileprivate static func createTesseract() -> G8Tesseract {
        let trainDataPath = bundle.path(forResource: "eng", ofType: "traineddata")
        
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let tessdataURL = cacheURL.appendingPathComponent("tesseract", isDirectory: true).appendingPathComponent("tessdata", isDirectory: true)
        let destinationURL = tessdataURL.appendingPathComponent("eng.traineddata")
        
        if !FileManager.default.fileExists(atPath: destinationURL.path) {
            createTessdataFrom(trainDataPath!, toDirectoryURL: tessdataURL, withDestinationURL: destinationURL)
        }
        
        let tesseract = G8Tesseract(language: "eng", configDictionary: [:], configFileNames: [], absoluteDataPath: tessdataURL.path, engineMode: .tesseractOnly, copyFilesFromResources: false)
        
        var whiteList = Constants.alphabet.uppercased()
        whiteList.append("<>1234567890")
        tesseract?.charWhitelist = whiteList
        
        tesseract?.setVariableValue("FALSE", forKey: "x_ht_quality_check")
        
        return tesseract!
    }
    
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
