//
//  AuthModel.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import Foundation
import UIKit

class User {
    
    struct Auth {
        static var uid: String? = nil
    }
    
    enum SignInWith: String {
        case Default
        case Google
        case Naver
        case Facebook
    }
    
    static var name: String? = nil
    static var userId: String? = nil
    static var profileImage: UIImage? = nil
    var didSigninWith: SignInWith = .Default
    
}
