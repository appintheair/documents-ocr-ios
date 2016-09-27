# DocumentsOCR

[![Version](https://img.shields.io/cocoapods/v/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![License](https://img.shields.io/cocoapods/l/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![Platform](https://img.shields.io/cocoapods/p/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)

## Screenshots 

![CameraOverlayView](http://s18.postimg.org/kto1gsn09/VV2_RO78u_XCM.jpg)

## Requirements

- XCode 8 +
- iOS 8.0 +

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Used frameworks 

DocumentOCR framework uses
- [TesseractOCR](https://github.com/gali8/Tesseract-OCR-iOS) text recognition of machine readable codes
- [PodAsset](http://cocoapods.org/pods/PodAsset) easy way to use pod assets
- [GPUImage](http://cocoapods.org/pods/GPUImage) helps to crop image from camera

## Installation

DocumentsOCR is [available](https://cocoapods.org/pods/DocumentsOCR) through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DocumentsOCR"
```

## Usage

### Import DocumentsOCR framework

```swift
    import DocumentsOCR
```

### Implement `DocumentScannerDelegate` protocol
 Create your custom class, which implemets `DocumentScannerDelegate` protocol

```swift
class ExampleViewController: UIViewController, DocumentScannerDelegate {
    	
    func documentScanner(scanner: DocumentScanner, willBeginScanningImage image: UIImage) {
        // do something with image
    }
    	
    func documentScanner(scanner: DocumentScanner, didFinishScanningWithInfo info: DocumentInfo) {
        // do something with DocumentInfo instance
    }	
    	
    func documentScanner(scanner: DocumentScanner, didFailWithError error: NSError) {
        // handle error
    }
    	
    // some other code here ...
}
```

### Create `DocumentScanner` instance

Initialize `DocumentScanner` instance with references to `UIViewController` and `DocumentScannerDelegate`
	
```swift
	var scanner = DocumentScanner(containerVC: self, withDelegate: self)
```

### Present camera controller

Scanner instance can present view controller with camera and border (actually, container view controller will do this inside document scanner instance).
```swift
	func someMethod() {
		scanner.presentCameraViewController()
	}
```

### Events after "take shoot" button pressed

After take shoot button pressed, these delegate methods called: 

```swift
    func documentScanner(scanner: DocumentScanner, willBeginScanningImage image: UIImage)

```

Then if image was recognized successfull:

```swift
    func documentScanner(scanner: DocumentScanner, didFinishScanningWithInfo info: DocumentInfo)
```

If some error happened

```swift
    func documentScanner(scanner: DocumentScanner, didFailWithError error: NSError)
```

## Author

Michael Babaev, mmbabaev@gmail.com

## License

DocumentsOCR is available under the MIT license. See the LICENSE file for more info.

## Issues:

Before using DocumentOCR, you must set Enable bitcode value to "No" in tesseract framework (target TesseractOCRiOS -> Build settings -> Enable Bitcode)

### TODO

- [x] documentation
- [x] fix minor UI defects in example 
- [x] code refactoring
- [x] pod string for all versions (without using ~> version")
- [ ] improve mr code recognition
- [ ] check visa document recognitions
- [ ] unit tests for camera shoots
- [ ] take many pictures when "take shoot" button pressed, then choose best image for recognition
