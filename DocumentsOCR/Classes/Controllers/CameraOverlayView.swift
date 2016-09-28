//
//  OverlayView.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

open class CameraOverlayView: UIView {
    
    @IBOutlet weak var codeBorder: UIView!
    
    var scanner: DocumentScanner!
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        scanner.containerViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        scanner.imagePicker.takePicture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.isOpaque = false
    }
}
