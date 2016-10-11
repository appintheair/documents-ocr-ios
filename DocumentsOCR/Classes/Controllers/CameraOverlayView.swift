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

public class CameraOverlayView: UIView {
    
    @IBOutlet weak var codeBorder: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressViewContainer: UIView!
    
    var delegate: CameraViewDelegate!
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        resetViews()
        delegate.stopTakingPictures()
    }
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        takePhotoButton.hidden = true
        progressViewContainer.hidden = false
        delegate.startTakingPictures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.opaque = false
    }
    
    func resetViews() {
        takePhotoButton.hidden = false
        progressLabel.text = ""
        progressView.progress = 0
        progressViewContainer.hidden = true
    }
}
