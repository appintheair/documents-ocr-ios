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
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressViewContainer: UIView!
    
    var delegate: CameraViewDelegate!
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        resetViews()
        delegate.stopTakingPictures()
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        takePhotoButton.isHidden = true
        progressViewContainer.isHidden = false
        delegate.startTakingPictures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.isOpaque = false
    }
    
    func resetViews() {
        takePhotoButton.isHidden = false
        progressLabel.text = "Taking pictures"
        progressView.progress = 0
        progressViewContainer.isHidden = true
    }
}
