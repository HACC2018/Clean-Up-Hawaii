
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
        self.date = Date()
        self.isComplete = false
        self.postId = "-1"
        
        self.getPostId()
    }
    
//    createPost(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ name: String, _ location : CLLocation){
//        let post = Post(image,title,city,state,name,location)
//        post.getPostId()
//    }
    
    func pushPost(){
        var postData = [String : String]()
        
        postData["city"] = city
       // postData["date"] = date
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
            Post.ref.child(id).child(i).observeSingleEvent(of: .value, with: { (snapshot) in
                //postData[i] = snapshot.value as? [String : AnyObject] ?? [:]
                print("Getting ID \(id): \(snapshot.value as? [String : AnyObject] ?? [:])")
            })
        }
        return Post(
            UIImage(named:"tempImage.png")!,
            postData["title"] ?? "Title",
            postData["city"] ?? "City",
            postData["state"] ?? "State",
            postData["name"] ?? "Name",
            CLLocation(latitude:Double(postData["lat"] ?? "0.0") ?? 0.0,longitude:Double(postData["long"] ?? "0.0") ?? 0.0)
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
            var getState : Bool = false
            Post.ref.child(id).child("state").observeSingleEvent(of: .value, with: { (snapshot) in
                //getState = snap.value?.description == state
                print("STATE: \(snapshot.value as? [String : AnyObject] ?? [:])")
            })
            if getState{
                Post.ref.child(id).child("city").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("CITY: \(snapshot.value as? [String : AnyObject] ?? [:])")
//                    if (snap.value as AnyObject).description == city{
//                        array.append(pullPost(id))
//                    }
                })
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
        Database.database().reference().observeSingleEvent(of: .value, with: { (snapshot) in
            let temp = snapshot.value as? [String : AnyObject] ?? [:]
            print("Temp: \(temp)")
            self.postId = temp["postId"] as! String ?? "0"
            print("Post ID: \(self.postId)")
            if(Int(self.postId)! < 5 ){
                Post.idRef.setValue(String(Int(self.postId)! + 1))
                
            }
        })
    }
}

