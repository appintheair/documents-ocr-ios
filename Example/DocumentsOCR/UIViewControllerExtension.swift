//
//  UIViewControllerExtension.swift
//  PassportOCR
//
//  Created by Михаил on 12.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlert(withMessage message: String) {
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
