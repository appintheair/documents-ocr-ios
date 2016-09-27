//
//  UIImageExtension.swift
//  PassportOCR
//
//  Created by Михаил on 11.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

extension UIImage {
    func croppedImageWithSize(rect: CGRect) -> UIImage {
        
        let imageRef: CGImageRef! = CGImageCreateWithImageInRect(self.CGImage!, rect)
        
        let croppedImage: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        let selectedFilter = GPUImageTransformFilter()
        selectedFilter.setInputRotation(kGPUImageNoRotation, atIndex: 0)
        let image: UIImage = selectedFilter.imageByFilteringImage(croppedImage)
        
        return image
    }
    
    func save(path: String) {
        let png = UIImagePNGRepresentation(self)
        png?.writeToFile(path, atomically: true)
    }
}
