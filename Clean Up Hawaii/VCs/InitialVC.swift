//
//  InitialVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 10/30/18.
//

import UIKit
import Firebase
class InitialVC: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Go To main Navigation View Controller
        self.goTo("MainNavVC", animate: false)
        
    }
 
}

//Various Methods
extension InitialVC{
    
    //Help Direct Initial VC to Navigation Controller
    private func goTo(_ view: String, animate: Bool){
        
        OperationQueue.main.addOperation {
            
            func topMostController() -> UIViewController {
                
                var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                
                while (topController.presentedViewController != nil) {
                    
                    topController = topController.presentedViewController!
                }
                return topController
            }
            
            if let second = topMostController().storyboard?.instantiateViewController(withIdentifier: view){
                
                topMostController().present(second, animated: false, completion: nil)
                
            }
            
        }
    }
    
    
    
}
