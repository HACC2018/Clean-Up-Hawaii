//
//  AboutVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 11/4/18.
//

import UIKit
class AboutVC: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func visitPressed(_ sender: Any) {
        
        if Reachability.isConnectedToNetwork(){
            UIApplication.shared.open(URL(string: "http://hacc.hawaii.gov")!, options: [:], completionHandler: nil)
        }else{
            alert(message: "There is no internet connection. Please check your internet connection and try again.",
                  title: "Connection Error")
        }
    }
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
