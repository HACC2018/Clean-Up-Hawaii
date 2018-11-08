
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
import Firebase
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
    
    static let storage = Storage.storage()
    static let storageRef = storage.reference()
    let imagesRef = storageRef.child("images")
    
    init(_ image: UIImage, _ title: String,_ city: String, _ state: String, _ name: String, _ location : CLLocation, _ postId : Int?){
        
        self.image = image
        self.title = title
        self.name = name
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
        
        
        Post.areaRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : [String : [String : String]]] ?? [:]
            if let ids = dict[self.state]?[self.city]?["postids"]{
                Post.areaRef.child("\(self.state)/\(self.city)/postids").setValue(
                    "\(ids),\(self.postId)"
                )
            }else{
                Post.areaRef.child("\(self.state)/\(self.city)/postids").setValue(
                    "\(self.postId)"
                )
            }
        })
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : [String : String]] ?? [:]
            if let ids = dict[User.getProcessedEmail()]?["postids"]{
                Database.database().reference().child("users/\(User.getProcessedEmail())").setValue(
                    "\(ids),\(self.postId)"
                )
            }else{
                Database.database().reference().child("users/\(User.getProcessedEmail())/postids").setValue(
                    "\(self.postId)"
                )
            }
//            let ref = Post.areaRef.child("\(state)/\(city)")
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
            
            post.pullImage(des)

            switch(des){
            case "home":
                HomeVC.posts.append(post)
                if HomeVC.postCount == HomeVC.posts.count{
                    doneLoading(des)
                }
                break
            case "profile":
                ProfileVC.profilePosts.append(post)
                if ProfileVC.postCount == ProfileVC.profilePosts.count{
                    doneLoading(des)
                }
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
            if dict[path[path.count-1]] == nil{
                //No post found
                switch(des){
                case "home":
                    HomeVC.postCount = 0
                    break
                case "profile":
                    ProfileVC.postCount = 0
                default:    break
                }
            }else{
                let ids = (dict[path[path.count-1]] as! String).components(separatedBy: ",")
                switch(des){
                case "home":
                    HomeVC.postCount = ids.count
                    break
                case "profile":
                    ProfileVC.postCount = ids.count
                default:    break
                }
                for id in ids{
                    pullPost(id,des)
                }
            }
        })

    }

    
    func saveImage(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "image.jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.pngData(),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
            } catch {
                print("file saved not:", error)
            }
        }
    }
    
    func pushImage(){
        let data = image.jpegData(compressionQuality: 0.0001)!
        
        // Create a reference to the file you want to upload
        let riversRef = Post.storageRef.child("images/\(postId).png")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }
    
    func bestPushImage(){
        let data = Data()
        
        // Create a reference to the file you want to upload
        let riversRef = Post.storageRef.child("-2")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            print("URL: \(metadata)")

            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print("SIZE:\(size)")
            // You can also access to download URL after upload.
            Post.storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print("URL: \(downloadURL)")
            }
        }
    }
    
    func pullImage(_ des:String){
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        print("PULLING")
        Post.storageRef.child("images/\(postId).png").getData(maxSize: 16 * 1024 * 1024) { data, error in
            if let _ = error {
                // Uh-oh, an error occurred!
                self.image = UIImage(named: "tempImage.png")!
            } else {
                // Data for "images/island.jpg" is returned
                self.image = UIImage(data: data!)!
                print("PULLING IMAGE: maybe good")
                switch(des){
                case "home" :NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeLoaded"), object: nil)
                    break

                case "profile":NotificationCenter.default.post(name: NSNotification.Name(rawValue: "profileLoaded"), object: nil)
                default:break

                }

            }
        }
    }
    
    static func doneLoading(_ des: String){
        print("Done Loading: \(des)")
        switch(des){
        case "home":
            HomeVC.posts = HomeVC.posts.sorted(by: { $0.postId > $1.postId })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeLoaded"), object: nil)
            HomeVC.refresh.endRefreshing()
            break
        case "profile":
            ProfileVC.profilePosts = ProfileVC.profilePosts.sorted(by: { $0.postId > $1.postId })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "profileLoaded"), object: nil)
            ProfileVC.refresh.endRefreshing()
        default:
            break
        }
    }
    
    func getPostId(){
        Post.idRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            self.postId = dict["post"] as! Int
            Post.idRef.child("post").setValue(self.postId + 1)
            self.pushPost()
            self.pushImage()
        })
    }
}

