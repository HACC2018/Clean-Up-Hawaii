//
//  ViewController.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import Firebase
import FirebaseUI

class HomeVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,FUIAuthDelegate {
    
    //Outlets and Vars
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet var mainCollectionView: UICollectionView!
    
    var loadActionsOnce = true
    static var userIsDeleted = false
    static var posts: [Post] = []
    static var imageArray : [UIImage] = []
    static var locationArray : [String] = []
    let actionSheet = UIAlertController(title: "Options",
                                        message: "Please select an option",
                                        preferredStyle: .actionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLoginState()

        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //Assign Data to collection view
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        Post.getPostAtPath(["locations","hawaii", "honolulu","postids"],"home")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //HomeVC.posts = []
    }
    
    
    //Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int {
        
        return HomeVC.posts.count
        
    }
    
    //Give each cell its properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "cell", for: indexPath)
            as! FeedCollectionViewCell
            
        let post = HomeVC.posts[indexPath.row]
        
        //Give each cell their properties
        cell.imageView.image = post.image
        
        cell.locationLabel.text = "\(post.city), \(post.state)"
            
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
        
        cell?.layer.borderWidth = 0.5
    }
    
    


}

//Various Methods
extension HomeVC{
    
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
//FireBase Authentication Code
extension HomeVC{

    //If admin deletes user account, it will bring them back to login
    
    /*
    private func deleteUser(){
        
        
        
        Auth.auth().currentUser?.delete(completion: { (err) in
            
            HomeVC.userIsDeleted = true

            //Logout User
            //self.loadLogin()
        })
        
        
    }*/

    //Check the login state of the user
    func loadLoginState(){
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is NOT nil")
            }else {
                self.loadLogin()
                print("User is nil")
                
            }
        }
    }
    
    //Display FireBase Auth. UI
    func loadLogin(){
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        
        if let authViewController = authUI?.authViewController(){
            
            self.present(authViewController, animated: false, completion: nil)
            
            print("Present")
            
        }else{
            print("No present")
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    //Handle Errors with loging in here
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        //Handle Errors here
        print("Error logging in  \(error?.localizedDescription ?? "Error")")
    }
    
}

//MARK: This Extension is used to edit FireBase Authentication UI
extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.4826237559, blue: 0.4760034084, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white
            ,NSAttributedString.Key.font : UIFont(name: "NoteWorthy", size: 22.0)!]
        self.navigationItem.title = "Hawai'i CleanUp Login"
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0.4826237559, blue: 0.4760034084, alpha: 1)
        
        /*
        //If User was deleted
        if HomeVC.userIsDeleted{
            
            alert(message: "Your account has been disabled by the developers. Creating new accounts will be unavailable",
                  title: "Account Disabled")
           

        }*/
       
    }

}

