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

public class Utils {

    private static let bundle = PodAsset.bundleForPod("DocumentsOCR")!
    static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    private static let tesseract = Utils.createTesseract()
    
    public static func stringFromTxtFile(_ fileName: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) -> String? {
        let filePath = bundle.pathForResource(fileName, ofType: "txt")
        let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
        return String(data: contentData!, encoding: NSUTF8StringEncoding)
    }
    
    static func mrCodeFrom(image: UIImage, tesseractDelegate: G8TesseractDelegate? = nil) -> String? {
        
        tesseract.delegate = tesseractDelegate!
        tesseract.image = image.recognitionImage
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            NSLog("Recognized: \(recognizedText)")
            
            let text = recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            let regex = try? NSRegularExpression(pattern: passportPattern, options: [])
            let range = NSRange(location: 0, length: text.characters.count)
            if let result = regex!.firstMatchInString(text, options: [], range: range) {
                
                let code = (text as NSString).substringWithRange(result.range)
                
                return fixFirstRowIn(code)
            }
        }
        
        return nil
    }
    
    private static func fixFirstRowIn(code: String) -> String {
        
        let pattern = "(?<FirstLine>(?<Passport>[A-Z0-9])(?<PassportType>.)(?<IssuingCountry>[A-Z0-9]{3})(?<PassportOwner>(?<Surname>[A-Z0-9]+)<<(?<GivenName>(?:[A-Z0-9]+<)+)){1})"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: code.characters.count)
        let result = regex!.matchesInString(code, options: [], range: range)
        var resultFirstRow = (code as NSString).substringWithRange(result[0].range)
        while resultFirstRow.characters.count != 44 {
            resultFirstRow.appendContentsOf("<")
        }
        
        let secondRow = code.characters.split("\n", maxSplit: 2, allowEmptySlices: true)[1]
        
        return "\(resultFirstRow)\n\(String(secondRow))\n"
    }
    
    private static func createTesseract() -> G8Tesseract {
        let fileManager = NSFileManager.defaultManager()
        
        let trainDataPath = bundle.pathForResource("eng", ofType: "traineddata")
        
        let cacheURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        let tessdataURL = cacheURL.URLByAppendingPathComponent("tesseract", isDirectory: true)!
        let destinationURL = tessdataURL.URLByAppendingPathComponent("eng.traineddata")!
        
        if !fileManager.fileExistsAtPath(destinationURL.path!) {
            createTessdataFrom(trainDataPath!, toDirectoryURL: tessdataURL, withDestinationURL: destinationURL)
        }

        NSLog("\(cacheURL.path)")
        NSLog("\(tessdataURL.path)")
        NSLog("\(destinationURL.path)")
        let tesseract = G8Tesseract(language: "eng", configDictionary: [:], configFileNames: [], cachesRelatedDataPath: "tesseract/tessdata", engineMode: .TesseractOnly)
        
        var whiteList = DOConstants.alphabet.uppercaseString
        whiteList.appendContentsOf("<>1234567890")
        tesseract?.charWhitelist = whiteList
        
        tesseract?.setVariableValue("FALSE", forKey: "x_ht_quality_check")
        
        return tesseract!
    }
    
    private static func createTessdataFrom(_ filePath: String, toDirectoryURL tessdataURL: NSURL, withDestinationURL destinationURL: NSURL) {
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
