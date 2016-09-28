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
    var timer: Timer?
    
    var scanner: DocumentScanner!
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        timer?.invalidate()
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.takePicture(_:)), userInfo: nil, repeats: true)
    }
    
    func takePicture(_ timer: Timer) {
        NSLog("TICK TICK TICK")
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
