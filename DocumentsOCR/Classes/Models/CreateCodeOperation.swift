//
//  CreateCodeOperation.swift
//  Pods
//
//  Created by Михаил on 28.09.16.
//
//

import Foundation
import TesseractOCR

class CreateCodeOperation: Operation {
    let image: UIImage
    let tesseractDelegate: G8TesseractDelegate
    let finishBlock: (String) -> Void
    
    init(image: UIImage, tesseractDelegate: G8TesseractDelegate, finishBlock: @escaping (String) -> Void) {
        self.image = image
        self.tesseractDelegate = tesseractDelegate
        self.finishBlock = finishBlock
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        if let info = DocumentInfo(image: image, tesseractDelegate: tesseractDelegate) {
            if isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.finishBlock(info.mrCode)
            }
        }
    }
}
