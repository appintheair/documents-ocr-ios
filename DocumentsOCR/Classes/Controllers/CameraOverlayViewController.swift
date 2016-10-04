//
//  CameraOverlayViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

class CameraOverlayViewController: UIViewController {    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let view = self.view as! CameraOverlayView
        view.takePhotoButton.isHidden = false
    }
}
