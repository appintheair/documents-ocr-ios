//
//  TakePhotoViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit
import Darwin
import DocumentsOCR

class PassportViewController: UITableViewController {

    var scanner: DocumentScanner!
    
    var selectedTextField: PassportTextField!
    
    @IBOutlet weak var countryField: PassportTextField!
    @IBOutlet weak var surnameField: PassportTextField!
    @IBOutlet weak var nameField: PassportTextField!
    @IBOutlet weak var numberField: PassportTextField!
    @IBOutlet weak var nationalityField: PassportTextField!
    @IBOutlet weak var dobField: PassportTextField!
    @IBOutlet weak var sexField: PassportTextField!
    @IBOutlet weak var expiredDateField: PassportTextField!
    @IBOutlet weak var personalNumberField: PassportTextField!
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    let countries = Utils.stringFromTxtFile("CountryCodes")!.componentsSeparatedByString("\n")
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        NSLog("\(paths)")
        
        scanner = DocumentScanner(containerVC: self, withDelegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.cameraImageView.contentMode = .ScaleAspectFit
        
        // Set up country fields:
        
        let countryPicker = UIPickerView()
        countryPicker.delegate = self
        countryPicker.dataSource = self
        
        countryPicker.showsSelectionIndicator = true
        
        countryField.delegate = self
        nationalityField.delegate = self
        
        countryField.inputView = countryPicker
        nationalityField.inputView = countryPicker
        
        
        // Set up date fields:
        
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(PassportViewController.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        datePicker.datePickerMode = UIDatePickerMode.Date
        
        dobField.delegate = self
        expiredDateField.delegate = self
        
        dobField.inputView = datePicker
        expiredDateField.inputView = datePicker
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        selectedTextField.text = sender.date.stringDate
    }
    
    @IBAction func cameraClicked(sender: UIBarButtonItem) {
        scanner.presentCameraViewController()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

extension PassportViewController: DocumentScannerDelegate {
    
    func documentScanner(scanner: DocumentScanner, willBeginScanningImage image: UIImage) {
        self.cameraImageView.image = image
    }
    
    func documentScanner(scanner: DocumentScanner, didFinishScanningWithInfo info: DocumentInfo) {
        NSLog("Info: \(info)")
        
        countryField.text = info.issuingCountryCode
        surnameField.text = info.lastname
        
        nameField.text = info.name
        numberField.text = info.passportNumber
        nationalityField.text = info.nationalityCode
        dobField.text = info.dateOfBirth?.stringDate
        
        let sex: String = {
            switch info.gender {
            case .Female:
                return "Женщина"
            case .Male:
                return "Мужчина"
            default:
                return "?"
            }
        }()
        sexField.text = sex
        expiredDateField.text = info.expirationDate?.stringDate
        personalNumberField.text = info.personalNumber

    }
    
    func documentScanner(scanner: DocumentScanner, didFailWithError error: NSError) {
        NSLog("Ошибка \(error.localizedDescription)")
        self.showErrorAlert(withMessage: error.localizedDescription)
    }
}

extension PassportViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        guard let passportField = textField as? PassportTextField else {
            NSLog("Ошибка: неверный тип текстового поля")
            return true
        }
        
        selectedTextField = passportField
        
        return true
    }
}

extension PassportViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField?.text = countries[row][0...2]
    }
}










