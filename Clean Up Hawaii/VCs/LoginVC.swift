//
//  LoginVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 10/29/18.
//
import UIKit
import FirebaseUI
import Foundation

class LoginVC : UIViewController, FUIAuthDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLogin()
    }
    
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
    
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        //If user did login
        if user != nil{
           navigateToMain()
            
        //If user hit cancel or error occured
        }else{
            loadLogin()
        }
    }
    
    func navigateToMain(){
        
        let MainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNavVC") as! UINavigationController
        present(MainNav, animated:true, completion: nil)
    }
    
    
}
