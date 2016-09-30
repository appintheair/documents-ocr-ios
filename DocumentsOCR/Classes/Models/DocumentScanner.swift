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
    /// - parameter progressRecognition: progress value from 0.0 to 1.0
    func documentScanner(_ scanner: DocumentScanner, recognitionProgress: Double)

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
 
    var timer: Timer!
    var codes = [String]()
    var images = [UIImage]()
    
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
                
                self.imagePicker.cameraOverlayView = overlayView
            })
        }
        else {
            let error = NSError(domain: DOErrorDomain, code: ErrorCodes.noCamera, userInfo: [
                NSLocalizedDescriptionKey : "Scanner unnable to find camera on this device"
                ])
            delegate.documentScanner(self, didFailWithError: error)
        }
    }
    
    
    fileprivate var cameraOverlayView: CameraOverlayView {
        let bundle = PodAsset.bundle(forPod: "DocumentsOCR")
        let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
        let overlayView = cameraVC.view as! CameraOverlayView
        
        return overlayView
    }
}

extension DocumentScanner: CameraViewDelegate {
    
    func stopTakingPictures() {
        timer.invalidate()
        DispatchQueue.main.async {
            self.containerViewController.dismiss(animated: true, completion: nil)
        }
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
        
        if images.count >= Int(photosCount) {
            delegate.documentScanner(self, willBeginScanningImages: images)
            
            queue.addOperation({
                self.scanPictures()
            })
        }
    }
    
    fileprivate func scanPictures() {
        stopTakingPictures()
        
        for index in 0 ..< images.count {
            let image = images[index]
            if let code = Utils.mrCodeFrom(image: image, tesseractDelegate: delegate) {
                codes.append(code)
            }
            let progress = Double(index + 1) / Double(images.count)
            
            DispatchQueue.main.async {
                self.delegate.documentScanner(self, recognitionProgress: progress)
            }
        }
        
        if codes.count == 0 {
            failToRecognizeError()
            return
        }
        
        var resultCode = ""
        
        let count = codes[0].characters.count
        for index in 0 ..< count {
            let winnerCharacter = chooseCharacterByVotesOn(index: index)
            resultCode.append(winnerCharacter)
        }
        
        if let info = DocumentInfo(recognizedText: resultCode) {
            DispatchQueue.main.async {
                self.delegate.documentScanner(self, didFinishScanningWithInfo: info)
            }
        }
        else {
            failToRecognizeError()
        }
    }
    
    fileprivate func failToRecognizeError() {
        DispatchQueue.main.async {
            let error = NSError(domain: DOErrorDomain, code: ErrorCodes.recognize, userInfo: [
                NSLocalizedDescriptionKey : "Scanner has failed to recognize machine readable code from camera"
                ])
            self.delegate.documentScanner(self, didFailWithError: error)
        }
    }
    
    fileprivate func chooseCharacterByVotesOn(index: Int) -> Character {
        let characters = codes.map({ $0[index] })
        
        var voting = [Character : Int]()
        for character in characters {
            if let count = voting[character] {
                voting[character] = count + 1
            }
            else {
                voting[character] = 1
            }
        }
        
        let max = voting.values.max()!
        for (character, count) in voting {
            if count == max {
                return character
            }
        }
        
        return characters[0]
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

