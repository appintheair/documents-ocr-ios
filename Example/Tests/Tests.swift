////
////  PassportOCRTests.swift
////  PassportOCRTests
////
////  Created by Михаил on 06.09.16.
////  Copyright © 2016 empatika. All rights reserved.
////
//
//import XCTest
//
//class PassportOCRTests: XCTestCase {
//    
//    override func setUp() {
//        super.setUp()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func testMrCode(text: String) {
//        let info = PassportInfo(recognizedText: text)
//        XCTAssert(info != nil)
//        if info != nil {
//            print(info!)
//        }
//    }
//    
//    func testCode1() {
//        let mrCode = "P<AFGERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\nL898902C<3AFG6908061F9406236ZE184226B<<<<<14"
//        testMrCode(mrCode)
//    }
//    
//    func testCode2() {
//        let mrCode = "P<BGDLIMA<<TASLIMA<AKTER<<<<<<<<<<<<<<<<<<<<\nAG81A8A126BGDB112255F1809118<<<<<<<<<<<<<<02"
//        testMrCode(mrCode)
//    }
//    
//    func testCode3() {
//        let mrCode = "P<IDNLENGKAP<<QAEA<E2Q<4<<EQQE<2A<KKQQ<K<<<<\nXOOOOOO<<QIDN450817981601269<<<<<<<<<<<<<<91"
//        testMrCode(mrCode)
//    }
//    
//    func testCode4() {
//        let mrCode = "P<IDNLENGKAP<<QAEA<E2Q<4<<EQQE<2A<KKQQ<K<<<<\nX000000<<910N4508179S1601269<<<<<<<<<<<<<<91"
//        testMrCode(mrCode)
//    }
//    
//    func testImageWithName(imageName: String) {
//        let info = PassportInfo(image: UIImage(named: imageName)!, tesseractDelegate: nil)
//        XCTAssert(info != nil)
//    }
//    
//    func testImage1() {
//        testImageWithName("1")
//    }
//    
//    func testImage2() {
//        testImageWithName("2")
//    }
//    
//    func testImage3() {
//        testImageWithName("3")
//    }
//    
//    func testImage4() {
//        testImageWithName("4")
//    }
//    
//    func testImage5() {
//        testImageWithName("5")
//    }
//    
//    func testPerformanceExample() {
//        self.measureBlock {
//            self.testCode2()
//        }
//    }
//}
