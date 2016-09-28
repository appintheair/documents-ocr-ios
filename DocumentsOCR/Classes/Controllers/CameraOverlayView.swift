//
//  OverlayView.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

protocol CameraViewDelegate {
    func stopTakingPictures()
    func startTakingPictures()
}

open class CameraOverlayView: UIView {
    
    @IBOutlet weak var codeBorder: UIView!
    
    var delegate: CameraViewDelegate!
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        delegate.stopTakingPictures()
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        delegate.startTakingPictures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.isOpaque = false
    }
}
