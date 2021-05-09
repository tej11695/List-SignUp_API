//
//  Extension.swift
//  Practical
//
//  Created by HariKrishna Kundariya on 13/07/20.
//  Copyright © 2020 HariKrishna Kundariya. All rights reserved.
//

import Foundation

extension String
{
    var isValidEmail: Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool
    {
        let phoneRegEx = "^[6-9]\\d{9}$"
        //let phoneRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
}


