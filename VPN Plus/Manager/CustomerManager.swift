//
//  CustomerManager.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/10/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import Foundation

final class CustomerManager {
    
    static let share = CustomerManager()
    
    private init() {}
    
    private let userDefault = UserDefaults.standard
    private let isShowedOnBoardingKey = "isShowedOnBoardingKey"
    
    public var isShowedOnBoarding: Bool {
        get {
            return userDefault.bool(forKey: isShowedOnBoardingKey)
        }
        set {
            userDefault.set(newValue, forKey: isShowedOnBoardingKey)
        }
    }
    
}
