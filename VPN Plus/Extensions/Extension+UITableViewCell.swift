//
//  Extension+UITableViewCell.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/10/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    
    static var cellId: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
}

