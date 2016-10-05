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
    /// - parameter images:  The cropped images from camera shoots
    func documentScanner(_ scanner: DocumentScanner, willBeginScanningImages: [UIImage])
    
    /// Tells the delegate that progress of photos recognition changed
    ///
    /// - parameter scanner:             The document scanner object informing the delegate of this event
    /// - parameter progress: progress value from 0.0 to 1.0
    func documentScanner(_ scanner: DocumentScanner, recognitionProgress progress: Double)

    /// Tells the delegate that scanner finished to recognize machine readable code from camera image and translate it into DocumentInfo struct
    ///
    /// - parameter scanner: The document scanner object informing the delegate of this event
    /// - parameter info:    The document info object containing information of document from camera shoot
    func documentScanner(_ scanner: DocumentScanner, didFinishScanningWithInfo info: DocumentInfo)
    
    
    /// Tells the delegate that some error happened
    ///
    /// - parameter scanner: The document scanner object informing the delegate of this event
    /// - parameter error:   The error object containing reason of failure
    func documentScanner(_ scanner: DocumentScanner, didFailWithError error: NSError)
}

open class DocumentScanner: NSObject {
    
    var imagePicker = UIImagePickerController()
    
    /// View controller, which will present camera image picker for document machine readable code
    open var containerViewController: UIViewController!
    
    /// The object that acts as the delegate of the document scanner
    open var delegate: DocumentScannerDelegate!
    
    /// Number of photos to recognize
    open var photosCount: UInt8 = 5
    
    /// Time interval between taking photos
    open var takePhotoInterval = 0.2
    
    /// Recognized document information from RecognitionOperation
    open var recognizedDocumentInfo: DocumentInfo? = nil
 
    var timer: Timer!
    var codes = [String]()
    var images = [UIImage]()
    var recognizedInfo: DocumentInfo? = nil
    
    fileprivate let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
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
    
    open func presentCameraViewController() {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.showsCameraControls = false
            
            imagePicker.delegate = self
            
            let overlayView = cameraOverlayView
            let width = self.imagePicker.view.frame.width
            let height = self.imagePicker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            imagePicker.modalPresentationStyle = .fullScreen
            containerViewController.present(imagePicker, animated: true, completion: {
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.red.cgColor
                
                overlayView.delegate = self
                overlayView.resetViews()
                
                self.imagePicker.cameraOverlayView = overlayView
            })
        }
        else {
            let error = NSError(domain: DOConstants.errorDomain, code: DOErrorCodes.noCamera, userInfo: [
                NSLocalizedDescriptionKey : "Scanner unnable to find camera on this device"
                ])
            delegate.documentScanner(self, didFailWithError: error)
        }
    }
    
    open func cancelRecognizeOperation() {
        queue.cancelAllOperations()
    }
    
    fileprivate var cameraOverlayView: CameraOverlayView = {
        let bundle = PodAsset.bundle(forPod: "DocumentsOCR")
        let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
        let overlayView = cameraVC.view as! CameraOverlayView
        
        return overlayView
    }()
}

extension DocumentScanner: CameraViewDelegate {
    
    func stopTakingPictures() {
        timer.invalidate()
        containerViewController.dismiss(animated: true, completion: nil)
    }
    
    func startTakingPictures() {
        codes = [String]()
        images = [UIImage]()
        
        timer = Timer.scheduledTimer(timeInterval: takePhotoInterval, target: self, selector: #selector(self.timerTick(sender:)), userInfo: nil, repeats: true)
    }
    
    func timerTick(sender: Timer) {
        imagePicker.takePicture()
    }
}

extension DocumentScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let image = editedImage ?? originalImage
        
        let cropped = cropImage(image)
        
        images.append(cropped)
        
        cameraOverlayView.progressView.progress = Float(images.count) / Float(photosCount)
        cameraOverlayView.progressLabel.text = "\(images.count) / \(photosCount)"
        
        if images.count >= Int(photosCount) {
            stopTakingPictures()
            
            cameraOverlayView.resetViews()
            
            delegate.documentScanner(self, willBeginScanningImages: images)
            
            let recognizeOperation = RecognizeOperation(scanner: self)
            
            recognizeOperation.completionBlock = {
                DispatchQueue.main.async {
                    if let info = self.recognizedInfo {
                        self.delegate.documentScanner(self, didFinishScanningWithInfo: info)
                    }
                    else {
                        let error = NSError(domain: DOConstants.errorDomain, code: DOErrorCodes.recognize, userInfo: [
                            NSLocalizedDescriptionKey : "Scanner has failed to recognize machine readable code from camera pictures"
                            ])
                        self.delegate.documentScanner(self, didFailWithError: error)
                    }
                }
            }
            
            queue.addOperation(recognizeOperation)
        }
    }

    fileprivate func cropImage(_ image: UIImage) -> UIImage {
        
        let viewControllerSize = containerViewController.view.frame.size
        let vcWidth = viewControllerSize.width
        let vcHeight = viewControllerSize.height
        
        let cameraImageWidth = image.size.width
        let cameraImageHeight = (cameraImageWidth * vcHeight) / vcWidth
        
        let vcBorderHeight = cameraOverlayView.codeBorder.frame.height
        let borderHeight = (vcBorderHeight * cameraImageWidth) / vcWidth
        
        let cameraImageY = (cameraImageHeight - borderHeight) / 2
        
        let rect = CGRect(x: cameraImageY, y: 0, width: borderHeight, height: image.size.width)
        
        return image.croppedImageWithSize(rect)
    }
}
