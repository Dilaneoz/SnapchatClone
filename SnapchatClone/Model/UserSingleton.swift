//
//  UserSingleton.swift
//  SnapchatClone
//
//  Created by Atil Samancioglu on 15.08.2019.
//  Copyright © 2019 Atil Samancioglu. All rights reserved.
//

import Foundation

class UserSingleton {
    
    static let sharedUserInfo = UserSingleton() // tek obje
    
    // taşımak istediğimiz veriler
    var email = ""
    var username = ""
    
    private init() {
        
    }
    
    
}
