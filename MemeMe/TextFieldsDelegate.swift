//
//  TextFieldsDelegate.swift
//  MemeMe
//
//  Created by Mustafa on 28/10/19.
//  Copyright © 2019 Mustafa Nafie. All rights reserved.
//

import Foundation
import UIKit

class TextFieldsDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear default text when the user starts editing
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when the user presses enter
        textField.resignFirstResponder()
        return true
    }
    
}
