//
//  DocumentScannerViewController.swift
//  Pods
//
//  Created by Михаил on 19.09.16.
//
//

import UIKit
import TesseractOCR
import PodAsset

/// The delegate of a DocumentScaner object must adopt the DocumentScannerDelegate protocol. Methods of protocol allow use result of document machine readable code recognition, handle errors if something went wrong. In addition, this protocol inherit G8TesseractDelegate protocol, so you can handle progress of image recognition (optional).
public protocol DocumentScannerDelegate: G8TesseractDelegate {
    
    /// Tells the delegate that user press take photo button, contains reference to cropped image from camera shoot
    ///
    /// - parameter scanner: The document scanner object informing the delegate of this event
    /// - parameter image:   The cropped image from camera shoot
    func documentScanner(scanner: DocumentScanner, willBeginScanningImage image: UIImage)
    
    /// Tells the delegate that scanner finished to recognize machine readable code from camera image and translate it into DocumentInfo struct
    ///
    /// - parameter scanner: The document scanner object informing the delegate of this event
    /// - parameter info:    The document info object containing information of document from camera shoot
    func documentScanner(scanner: DocumentScanner, didFinishScanningWithInfo info: DocumentInfo)

    
    /// Tells the delegate that some error happened
    ///
    /// - parameter scanner: The document scanner object informing the delegate of this event
    /// - parameter error:   The error object containing reason of failure
    func documentScanner(scanner: DocumentScanner, didFailWithError error: NSError)
}

public class DocumentScanner: NSObject {

    var imagePicker = UIImagePickerController()
    
    /// View controller, which will present camera image picker for document machine readable code
    public var containerViewController: UIViewController!
    
    /// The object that acts as the delegate of the document scanner
    public var delegate: DocumentScannerDelegate!
    
    private let queue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        queue.name = "ScannerOperationQueue"
        return queue
    }()
    
    /**
     Initializes and returns a new document scanner with the provided container view controller and delegate
     
     - parameter containerVC: View controller, which will present camera image picker for document machine readable code
     - parameter delegate: The object that acts as the delegate of the  scanner
     
     - Returns: The document scanner instance
     */

    public init(containerVC: UIViewController, withDelegate delegate: DocumentScannerDelegate) {
        self.delegate = delegate
        self.containerViewController = containerVC
    }
    
    /// Present view controller with camera and border for document machine readable code
    
    public func presentCameraViewController() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.showsCameraControls = false
            
            imagePicker.delegate = self
            
            let overlayView = cameraOverlayView
            let width = self.imagePicker.view.frame.width
            let height = self.imagePicker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            imagePicker.modalPresentationStyle = .FullScreen
            containerViewController.presentViewController(imagePicker, animated: true, completion: {
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.redColor().CGColor
                
                overlayView.scanner = self
                
                self.imagePicker.cameraOverlayView = overlayView
            })
        }
        else {
            let error = NSError(domain: DOErrorDomain, code: 1, userInfo: [
                NSLocalizedDescriptionKey : "Scanner unnable to find camera on this device"
                ])
            self.delegate.documentScanner(self, didFailWithError: error)
        }
    }
    
    
    private var cameraOverlayView: CameraOverlayView {
        let bundle = PodAsset.bundleForPod("DocumentsOCR")
        let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
        let overlayView = cameraVC.view as! CameraOverlayView
        return overlayView
    }
}

extension DocumentScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let image = editedImage ?? originalImage
        
        let cropped = cropImage(image)
        
        containerViewController.dismissViewControllerAnimated(true, completion: nil)
        
        delegate.documentScanner(self, willBeginScanningImage: cropped)
        
        queue.addOperationWithBlock {
            let infoOpt = DocumentInfo(image: cropped, tesseractDelegate: self.delegate)
            
            dispatch_async(dispatch_get_main_queue()) {
                if let info = infoOpt {
                    self.delegate.documentScanner(self, didFinishScanningWithInfo: info)
                }
                else {
                    let error = NSError(domain: DOErrorDomain, code: 0, userInfo: [
                        NSLocalizedDescriptionKey : "Scanner has failed to recognize machine readable code from camera picture"
                        ])
                    self.delegate.documentScanner(self, didFailWithError: error)
                }
            }
        }

    }
    
    private func cropImage(image: UIImage) -> UIImage {
        NSLog("image size: \(image.size)")
        NSLog("vc size: \(containerViewController.view.frame.size)")
        NSLog("border size: \(cameraOverlayView.codeBorder.frame.size)")
        
        let viewControllerSize = containerViewController.view.frame.size
        let vcWidth = viewControllerSize.width
        let vcHeight = viewControllerSize.height
        
        let cameraImageWidth = image.size.width
        let cameraImageHeight = (cameraImageWidth * vcHeight) / vcWidth
        
        let vcBorderHeight = cameraOverlayView.codeBorder.frame.height
        let borderHeight = (vcBorderHeight * cameraImageWidth) / vcWidth
        
        let cameraImageY = (cameraImageHeight - borderHeight) / 2
        
        let rect = CGRectMake(cameraImageY, 0, borderHeight, image.size.width)

        return image.croppedImageWithSize(rect)
    }
}

