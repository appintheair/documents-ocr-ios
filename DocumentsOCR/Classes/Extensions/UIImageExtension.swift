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
        
        let imageRef: CGImage! = self.cgImage!.cropping(to: rect)
        
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        let selectedFilter = GPUImageTransformFilter()
        selectedFilter.setInputRotation(kGPUImageNoRotation, at: 0)
        let image: UIImage = selectedFilter.image(byFilteringImage: croppedImage)
        
        return image
    }
    
    func save(_ path: String) {
        let png = UIImagePNGRepresentation(self)
        try? png?.write(to: URL(fileURLWithPath: path), options: [.atomic])
    }
}
