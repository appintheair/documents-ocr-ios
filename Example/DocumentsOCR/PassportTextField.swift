//
//  PassportTextField.swift
//  PassportOCR
//
//  Created by Михаил on 14.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

enum TextFieldType {
    case name, date, text, sex, country, none
}

class PassportTextField: UITextField {
    var editType: TextFieldType {
        set {
            editTypeValue = String(describing: newValue)
        }
        get {
            switch editTypeValue {
            case "Name": return .name
            case "Date": return .date
            case "Text": return .text
            case "Sex": return .sex
            case "Country": return .country
            default: return .none
            }
        }
    }
    @IBInspectable var editTypeValue: String = "None"
}
