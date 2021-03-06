//
//  ProfileVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 11/1/18.
//

import Foundation
import UIKit
import MapKit

class ProfileVC : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet weak var indicatorOutlet: UIActivityIndicatorView!
    
    @IBOutlet var profileCollectionView: UICollectionView!
    
    static let refresh =  UIRefreshControl()
    
    var loadActionsOnce = true
    static var profilePosts: [Post] = []
    static var postCount = 0
    let actionSheet = UIAlertController(title: "Options",
                                        message: "Please select an option",
                                        preferredStyle: .actionSheet)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startIndicator()
        callRefresher()
        
        //Hides back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfile), name:NSNotification.Name(rawValue: "profileLoaded"), object: nil) //Connects instance method to other VC
        
        //Assign Data to collection view
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        
        updateProfile()
 
    }
    
    //Refresh feed
    private func callRefresher(){
        ProfileVC.refresh.attributedTitle = NSAttributedString(string: "")
        ProfileVC.refresh.tintColor = UIColor.white
        ProfileVC.refresh.addTarget(self, action: #selector(updateProfile), for: UIControl.Event.valueChanged)
        //addTarget(self, action: #(updateFeed), for: .valueChanged)
        profileCollectionView.refreshControl = ProfileVC.refresh
    }
    
    func startIndicator(){
        indicatorOutlet.startAnimating()
        indicatorOutlet.color = UIColor.white
        indicatorOutlet.isHidden = false
    }
    func stopIndicator(){
        indicatorOutlet.stopAnimating()
        indicatorOutlet.isHidden = true
    }
    
    @objc func updateProfile(){
        print("Updating Feed")
        ProfileVC.profilePosts = []
        Post.getPostAtPath(["users",User.getProcessedEmail(),"postids"],"profile")
        
        
    }
    
    @objc func reloadProfile(){
        print("Reload posts")
        profileCollectionView.reloadData()
        stopIndicator()
    }
    
    //Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int {
            
            return ProfileVC.profilePosts.count
            
    }
    
    //Give each cell its properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "cell", for: indexPath)
                as! ProfileCollectionViewCell
            
            let post = ProfileVC.profilePosts[indexPath.row]
            
            //Give each cell their properties
            cell.imageView.image = post.image
            
            cell.locationLabel.text = "\(post.city), \(post.state)".localizedCapitalized
            
            cell.userLabel.text = "\(post.name)"
            
            cell.titleLabel.text = "\(post.title)"
            
            cell.layer.borderColor = UIColor.darkGray.cgColor
            
            cell.layer.borderWidth = 0.5
            
            return cell
            
    }
    
    //Select Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.layer.borderWidth = 0.5
        
        if loadActionsOnce{
            
            loadActionsOnce = false
            
            addActions(title: "Location")
            addActions(title: "Done Cleaning (Take Off Feed)")
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    //Deselected Item
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.layer.borderColor = UIColor.darkGray.cgColor
        
        //  cell?.backgroundColor = UIColor.black
        
        cell?.layer.borderWidth = 0.5
    }
}


//Various Methods
extension ProfileVC{
    
    //MARK: When USER selects post
    private func addActions(title name: String){
        
        actionSheet.addAction(UIAlertAction(title: "\(name)", style: .default, handler:
            {(action:UIAlertAction) in
                
                if name == "Location"{
                    
                    self.openMaps()
                    
                }else{
                    
                    print("You clicked take off feed")
                    //TODO: Take cell of feed
                    
                }
                
        }))
        
        
        
    }
    
    private func openMaps(){
        
        if let latitude = AddVC.currentLocation?.coordinate.latitude,
            let longitude = AddVC.currentLocation?.coordinate.longitude {
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Trash Location"
            mapItem.openInMaps(launchOptions: options)
            
        }else{
            self.alert(message: "There was no location assigned to this post",
                       title: "Location Uavailable")
        }
        
        
    }
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
