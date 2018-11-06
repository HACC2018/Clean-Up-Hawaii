
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
    var postId : Int
    var isComplete : Bool
    
    static let idRef = Database.database().reference().child("ids")
    static let ref = Database.database().reference().child("posts")
    static let areaRef = Database.database().reference().child("locations")
    static let variables = ["title","city","state","name","lat","long"]
    
    init(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ name: String, _ location : CLLocation, _ postId : Int?){
        
        self.image = image
        self.title = title
        self.name = "Posted By: \(name)"
        self.location = location
        self.city = city
        self.state = state
        self.date = Date()
        self.isComplete = false
        self.postId = postId == nil ? -1 : postId!
        
        if self.postId < 0{
            self.getPostId()
            
        }
    }
    
//    createPost(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ name: String, _ location : CLLocation){
//        let post = Post(image,title,city,state,name,location)
//        post.getPostId()
//    }
    
    func getDate(_ raw : Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: raw)
    }
    
    func pushPost(){
        var postData = [String : String]()
        
        postData["city"] = city
        
        
        postData["date"] = getDate(date)
        postData["isComplete"] = String(isComplete)
        postData["lat"] = String(location.coordinate.latitude)
        postData["long"] = String(location.coordinate.longitude)
        postData["name"] = name
        postData["state"] = state
        postData["title"] = title
        //postData["imageName"] = imageName
        print("Posting: \(postData) -> \(postId)")
        Post.ref.child(String(postId)).setValue(postData)
        
        Post.areaRef.child(state).child(city).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            let ids = dict["postids"] as! String
            Post.areaRef.child(self.state).child(self.city).child("postids").setValue("\(ids),\(self.postId)")
        })
    }
    
    static func pullPost(_ id : String, _ des : String){
        Post.ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let postData = snapshot.value as? [String : AnyObject] ?? [:]
            let post = Post(
                UIImage(named:"tempImage.png")!,
                postData["title"] as? String ?? "NA",
                postData["city"] as? String ?? "NA",
                postData["state"] as? String ?? "NA",
                postData["name"] as? String ?? "NA",
                CLLocation(latitude:Double(postData["lat"] as? String ?? "0.0") ?? 0.0,longitude:Double(postData["long"]  as? String ?? "0.0") ?? 0.0),Int(id))
            
            switch(des){
            case "home":
                HomeVC.posts.append(post)
            default:
                break
            }
        })
    }
    
    static func getPostAtPath(_ path : [String], _ des : String){
        
    
        var db = Database.database().reference()
        for i in 0..<path.count-1{
            db = db.child(path[i])
        }
        
        db.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            let ids = (dict[path[path.count-1]] as! String).components(separatedBy: ",")
            for id in ids{
                print("Found IDS: \(id)")
                pullPost(id,des)
            }
        })

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
        Post.idRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            self.postId = dict["post"] as! Int
            Post.idRef.child("post").setValue(self.postId + 1)
            self.pushPost()
        })
    }
}

