//
//  PassportTextField.swift
//  PassportOCR
//
//  Created by Михаил on 14.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

enum TextFieldType {
    case Name, Date, Text, Sex, Country, None
}

class PassportTextField: UITextField {
    var editType: TextFieldType {
        set {
            editTypeValue = String(newValue)
        }
        get {
            switch editTypeValue {
            case "Name": return .Name
            case "Date": return .Date
            case "Text": return .Text
            case "Sex": return .Sex
            case "Country": return .Country
            default: return .None
            }
        }
    }
    @IBInspectable var editTypeValue: String = "None"
}
