//
//  RecognitionOperation.swift
//  Pods
//
//  Created by Михаил on 01.10.16.
//

import Foundation

class RecognizeOperation: Operation {

    let scanner: DocumentScanner
    var codes = [String]()
    
    init (scanner: DocumentScanner) {
        self.scanner = scanner
    }
    
    override func main() {

        let images = scanner.images
        
        for index in 0 ..< images.count {

            let image = images[index]
            
            if isCancelled {
                return
            }
            
            if let code = Utils.mrCodeFrom(image: image, tesseractDelegate: scanner.delegate) {
                codes.append(code)
            }

            let progress = Double(index + 1) / Double(images.count)
            
            DispatchQueue.main.async {
                self.scanner.delegate.documentScanner(self.scanner, recognitionProgress: progress)
            }
        }
        
        if codes.count == 0 {
            return
        }
        
        var resultCode = ""
        let count = codes.first!.count

        for index in 0 ..< count {

            if isCancelled {
                return
            }
            
            let winnerCharacter = chooseCharacterByVotesOn(index: index)
            resultCode.append(winnerCharacter)
        }
        
        if isCancelled {
            return
        }
        
        if let info = DocumentInfo(recognizedText: resultCode) {
            scanner.recognizedInfo = info
        }
    }
    
    fileprivate func chooseCharacterByVotesOn(index: Int) -> Character {

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
        
        let max = voting.values.max()!

        for (character, count) in voting {
            if count == max {
                return character
            }
        }
        
        return characters.first!
    }
}
