//
//  RecognitionOperation.swift
//  Pods
//
//  Created by Михаил on 01.10.16.
//
//

import Foundation

class RecognizeOperation: NSOperation {
    let scanner: DocumentScanner
    var codes = [String]()
    
    init (scanner: DocumentScanner) {
        self.scanner = scanner
    }
    
    override func main() {
        let images = scanner.images
        
        for index in 0 ..< images.count {
            let image = images[index]
            
            if cancelled {
                return
            }
            
            if let code = Utils.mrCodeFrom(image, tesseractDelegate: scanner.delegate) {
                codes.append(code)
            }
            let progress = Double(index + 1) / Double(images.count)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.scanner.delegate.documentScanner(self.scanner, recognitionProgress: progress)
            }
        }
        
        if codes.count == 0 {
            return
        }
        
        var resultCode = ""
        
        let count = codes.first!.characters.count
        for index in 0 ..< count {
            if cancelled {
                return
            }
            
            let winnerCharacter = chooseCharacterByVotesOn(index)
            resultCode.append(winnerCharacter)
        }
        
        if cancelled {
            return
        }
        
        if let info = DocumentInfo(recognizedText: resultCode) {
            scanner.recognizedInfo = info
        }
    }
    
    private func chooseCharacterByVotesOn(index: Int) -> Character {
        let characters = codes.map({ $0[index] })
        
        var voting = [Character : Int]()
        for character in characters {
            if let count = voting[character] {
                voting[character] = count + 1
            }
            else {
                voting[character] = 1
            }
        }
        
        let max = voting.values.maxElement()!
        for (character, count) in voting {
            if count == max {
                return character
            }
        }
        
        return characters.first!
    }
}
