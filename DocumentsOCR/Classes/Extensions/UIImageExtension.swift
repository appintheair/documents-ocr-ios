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
    func croppedImageWithSize(_ rect: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(self.CGImage!, rect)
        
        let croppedImage: UIImage = UIImage(CGImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        let selectedFilter = GPUImageTransformFilter()
        selectedFilter.setInputRotation(kGPUImageNoRotation, atIndex: 0)
        let image = selectedFilter.imageByFilteringImage(croppedImage)
        
        return image
    }
    
    var recognitionImage: UIImage {
        return UIImage(CGImage: self.CGImage!, scale: self.scale, orientation: UIImageOrientation.Left)
    }
}
