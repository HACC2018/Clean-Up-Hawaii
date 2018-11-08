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
    
    static func getProcessedEmail() -> String{
        return format(getEmail())
    }
    
    static func format(_ s : String) -> String{

        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890 ")
        return s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().components(separatedBy: set.inverted).joined()
        
        
    }

    
}
