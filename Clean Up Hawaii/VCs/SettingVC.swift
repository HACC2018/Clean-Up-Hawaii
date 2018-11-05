//
//  SettingVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import Foundation
import FirebaseUI
import SystemConfiguration
import MessageUI

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    let authUI = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)
 
    }


    @IBAction func playPressed(_ sender: Any) {
        //Check for internet
        if Reachability.isConnectedToNetwork(){
            //Open Aloha Surfer
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1327714603")!, options: [:], completionHandler: nil)

        }else{
            
            alert(message: "There is no internet connection. Please check your internet connection and try again.",
                  title: "Connection Error")
        }
        
        
    }
    @IBAction func contactPressed(_ sender: Any) {
        
        //Check for internet
        if Reachability.isConnectedToNetwork(){
            //Send email to developer
            sendEmail()
            
        }else{
            
            alert(message: "There is no internet connection. Please check your internet connection and try again.",
                  title: "Connection Error")
        }
 
    }
    @IBAction func ratePressed(_ sender: Any) {
        
        //Check for internet
        if Reachability.isConnectedToNetwork(){
            //PUT LINK HERE WHEN AVAIBALE ON STORE
            
        }else{
            
            alert(message: "There is no internet connection. Please check your internet connection and try again.",
                  title: "Connection Error")
        }
        
        
    }
    @IBAction func pressedSignOut(_ sender: Any) {
        do{
            
            try authUI?.signOut()
            
        }catch{
            print("Problem has occured signing out")
        }
        
    }
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendEmail(){
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hawaiicleanup@gmail.com"])
            mail.setSubject("Question From User")
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }

}
//Check if internet is avaiable
class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
