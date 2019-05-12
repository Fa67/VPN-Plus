//
//  Button.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/10/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Button: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0.0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
        
}
