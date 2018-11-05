
//
//  Post.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline and Friends on 10/29/18.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseDatabase

class Post{
    
    var image : UIImage
    var title : String
    var name: String
    var location : CLLocation
    var city : String
    var state : String
    var date : Date
    var postId : String
    var isComplete : Bool
    
    static let idRef = Database.database().reference().child("postId")
    static let ref = Database.database().reference().child("posts")
    static let variables = ["title","city","state","name","lat","long"]
    
    init(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ name: String, _ location : CLLocation){
        
        self.image = image
        self.title = title
        self.name = "Posted By: \(name)"
        self.location = location
        self.city = city
        self.state = state
        self.date =
        self.isComplete = false
        
        getPostId()
    }
    
    func pushPost(){
        var postData = [String : String]()
        
        postData["city"] = city
        postData["date"] = date
        postData["isComplete"] = String(isComplete)
        postData["lat"] = String(location.coordinate.latitude)
        postData["long"] = String(location.coordinate.longitude)
        postData["name"] = name
        postData["state"] = state
        postData["title"] = title
        //postData["imageName"] = imageName
        Post.ref.child(postId).setValue(postData)
    }
    
    static func pullPost(_ id : String) -> Post{
        var postData = [String:String]()
        for i in variables{
            Post.ref.child(id).child(i).observeEventType(.Value){ (snap: FIRDataSnapshot) in
                postData[i] = snap.value?.description
            }
        }
        return Post(
            UIImage(named:"postBack.png"),
            postData["title"],
            postData["city"],
            postData["state"],
            postData["name"],
            CLLocation(latitude:Double(postData["lat"]),longitude:Double(postData["long"]))
        )
    }
    
    static func pullAllPostKeys() -> [String]{
        var array : [String] = []
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                array.append(snap.key)
            }
        })
        return array
    }
    
    static func pullLocal(_ state : String, _ city : String) -> [Post]{
        let all = pullAllPostKeys()
        var array : [Post] = []
        for id in all{
            var getState : Bool
            Post.ref.child(id).child("state").observeEventType(.Value){ (snap: FIRDataSnapshot) in
                getState = snap.value?.description == state
            }
            if getState{
                Post.ref.child(id).child("city").observeEventType(.Value){ (snap: FIRDataSnapshot) in
                    if snap.value?.description == city{
                        array.append(pullPost(id))
                    }
                }
            }
        }
        return array
    }
    
//    static func pullUser(_ email : String) -> [Post]{
//        let all = pullAllPostKeys()
//        var array : [Post] = []
//        for id in all{
//            Post.ref.child(id).child("n").observeEventType(.Value){ (snap: FIRDataSnapshot) in
//                if snap.value?.description == city{
//                    array.append(pullPost(id))
//                }
//            }
//        }
//        return array
//    }
    
    func getPostId(){
        Post.idRef.observeEventType(.Value){ (snap: FIRDataSnapshot) in
            postId = snap.value?.description
            Post.idRef.setValue(String(Int(postId) + 1))
        }
    }
}

