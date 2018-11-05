//
//  Post.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 10/29/18.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
class User{
    
    var email : String
    var name : String

    init(name : String, email : String){
     
        self.name = name
        self.email = email
    
     }
    
    static func pull() -> [Post]{
        let posts : [Post] = []
        return posts
    }
    
    static func getName() -> String{
        return Auth.auth().currentUser?.displayName ?? "-Unknown-"
    }
    
    static func getEmail() -> String{
        return Auth.auth().currentUser?.email ?? "-Unknown-"
    }

    
}
