//
//  AddVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import CoreLocation

class AddVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate {
    
   static var currentLocation: CLLocation?
    
   var locManager = CLLocationManager()
    
   var addedLocation = false
    
    //Outlets and variables
    @IBOutlet var confirmationOutlets: [UIImageView]!
    
    @IBOutlet var chosenImageView: UIImageView!
    
    let actionSheet = UIAlertController(title: "Photo Source",
                                        message: "Choose a source",
                                        preferredStyle: .actionSheet)
    
    var loadActionsOnce = true
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)

       
    }
    
    //Location not found
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
        
        //Don't Confirm
        confirmationButtons(index: 1, confirm: false)
        
        //Tell user why location cant be determined
        alert(message: "Please turn on location services for this app in settings",
              title: "Location Services Disabled")
    }
    

    @IBAction func pickImagePressed(_ sender: Any) {

        //Create and present action sheet
        //Add actions once so they don't replicate
        if loadActionsOnce{
            
            loadActionsOnce = false
            
            addActionsForImage(title: "Camera")
            addActionsForImage(title: "Photo Library")
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    

    @IBAction func addPostPressed(_ sender: Any) {
        
        validatePost()
    }
        
    //Action Sheet for Selecting an Image
    private func addActionsForImage(title name: String){
        
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        
        actionSheet.addAction(UIAlertAction(title: "\(name)", style: .default,
                                            handler: {(action:UIAlertAction) in
            
            if name == "Camera"{
                
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController,animated: true,completion: nil)
                }else{
                    
                    self.alert(message: "Unable to locate Camera",
                          title: "No Camera Available")
                    print("No avaiable camera")
                    
                }
             
                
            }else{
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController,animated: true,completion: nil)
            }
            
        }))
        
        
        
    }
    
    //MARK: Map button is pressed
    @IBAction func mapPressed(_ sender: Any) {
       
        getLocation()
        
        addedLocation = true
   

    }
    
    private func getLocation(){
        
        //This will locate their current location on apple maps
        //This does ask permission before locating User (Asking permission is done in Info.plst)
        //TODO: If they choose no for location, need to make sure we tell them where to go to turn it on
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {
                
                self.locationManager.requestWhenInUseAuthorization()

            }
            
            //Confirmation green check
            confirmationButtons(index: 1, confirm: true)
            
            //Store location in variable
            AddVC.currentLocation = locManager.location

            self.locationManager.desiredAccuracy = 1.0
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            
       
            
        } else {
            //TODO: This is not working
            alert(message: "Please go to your settings and turn on Location Services",
                  title: "Turn On Location Services")
        }
        
 
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        chosenImageView.image = image
        
        //Confirm Image was selected
        confirmationButtons(index: 0, confirm: true)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
  
    
}


//Various Methods
extension AddVC{
    
    //Push alert to user
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Call to Segue to homepage
    private func navigateToHome(){
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let navigationVC = mainStoryboard.instantiateViewController(withIdentifier: "MainNavVC")
            as? MainNavVC else{
                
                return
                
        }
        
        present(navigationVC, animated: true, completion: nil)
    }
    
    
    private func validatePost(){
        
        //Used to check if value is nil
        let checkChosenImage = chosenImageView.image
        let checkCurrentLocation = AddVC.currentLocation
        
        if checkChosenImage == nil{
            
            alert(message: "Please select an image before posting to feed",
                  title: "No Image Selected")
            
            
        }
        if checkCurrentLocation == nil{
            
            alert(message: "Please click 'Add Current Location' ",
                  title: "Current Location Not Added")
            
        }else{
            
            //TODO: Shift everythign to the rigHT ONE AND ADD new post at top of feed
            
            //Without this if statment app will crash if you add location but not image
            //Double check that the image var is not nill so it does not crash
            if checkChosenImage != nil{
                
                //Make sure user adds location more clicking add
                //This makes sure they don't use same location from before if
                //They are posting mutiple in a close time frame without closing app
                if addedLocation{
                    
                    HomeVC.imageArray.append(checkChosenImage!)
                    HomeVC.locationArray.append("Location")
                    navigateToHome()
                    
                }else{
                    alert(message: "Please click 'Add Current Location' ",
                          title: "Current Location Not Added")
                    
                }
                
                
            }
            
        }
    }
    private func confirmationButtons(index: Int, confirm: Bool){
        
        if confirm{
            
            confirmationOutlets[index].image = UIImage(named: "greenCheck")
        }else{
            
            confirmationOutlets[index].image = UIImage(named: "redX")
            
        }
        
        
    }
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any])
    -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey)
    -> String {
	return input.rawValue
}
