//
//  SettingVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import Foundation
import FirebaseUI

class SettingsVC: UIViewController {
    
    let authUI = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)
 
    }
    

    @IBAction func pressedSignOut(_ sender: Any) {
        do{
            
            try authUI?.signOut()
            
        }catch{
            print("Problem has occured signing out")
        }
        
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }
    

    
}
