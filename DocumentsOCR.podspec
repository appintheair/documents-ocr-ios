#
# Be sure to run `pod lib lint DocumentsOCRiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DocumentsOCR'
  s.version          = '1.0.5'
  s.summary          = 'A Swift framework for machine readable documents recognition'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!


  s.homepage         = 'https://github.com/appintheair/documents-ocr-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Michael' => 'mmbabaev@gmail.com' }
  s.source           = { :git => 'https://github.com/appintheair/documents-ocr-ios', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DocumentsOCR/Classes/**/*'
  
  s.resource_bundles = {
  	'DocumentsOCR' => ['DocumentsOCR/Assets/CameraOverlayViewController.xib',
  						  'DocumentsOCR/Assets/passportPattern.txt',
                        'DocumentsOCR/Assets/*.png',
                        'DocumentsOCR/Assets/tessdata/eng.traineddata']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  
  s.dependency 'TesseractOCRiOS', '~> 4.0.0'
  s.dependency 'PodAsset'
  s.dependency 'GPUImage'
end
