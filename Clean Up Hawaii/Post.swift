//
//  Post.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 10/29/18.
//

import Foundation
import UIKit
import CoreLocation

class Post{
    
    
    var image : UIImage
    var title : String = ""
    var userName: String = ""
    var location : CLLocation
    var state : String
    var city : String
    var date: Date
    
    
    
    init(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ userName: String, _ location : CLLocation){
     
        self.image = image
        self.title = title
        self.userName = "Posted By: \(userName)"
        self.location = location
        self.date = Date()
        self.city = city
        self.state = state

    }
    
    func push(){
        
    }
    
    static func pull() -> [Post]{
        let posts : [Post] = []
        return posts
    }
    
    
    
    
}
