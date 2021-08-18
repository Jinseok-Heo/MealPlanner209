//
//  AuthModel.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import Foundation
import UIKit
import CoreData

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
    static var profileImageURL: URL? = nil
    static var profileImage: Data? {
        guard let url = profileImageURL else { return nil }
        let imageData = try? Data(contentsOf: url)
        return imageData
    }
    static var didSigninWith: SignInWith = .Default
    
    static var user: UserInfo? = nil
    
    class func deleteUser() {
        Auth.uid = nil
        name = nil
        userId = nil
        profileImageURL = nil
        user = nil
    }
    
}
