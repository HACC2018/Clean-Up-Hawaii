//
//  AddVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import CoreLocation

class AddVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate,UITextFieldDelegate {

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var cityTextField: UITextField!
    @IBOutlet private weak var stateTextField: UITextField!
    @IBOutlet var chosenImageView: UIImageView!
    @IBOutlet weak var postOutlet: UIButton!
    
    static var currentLocation: CLLocation?
    private var showTempImage = true
    private var locManager = CLLocationManager()
    private var addedLocation = false
    private var loadActionsOnce = true
    private var locationManager = CLLocationManager()
    
    let actionSheet = UIAlertController(title: "Photo Source",
                                        message: "Choose a source",
                                        preferredStyle: .actionSheet)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If you tap out of textfield, textfield will dissappear
        self.hideKeyboard()
        
        getLocation()
        
       
    
        configureTextFields()
        setTextFieldTags()
        
        if AddVC.currentLocation != nil{
            
            addedLocation = true
        }
 
    }
        //Character Limit in each text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 20
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    
    //What happens when you hit retun on text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0{
            cityTextField.becomeFirstResponder()
        }else if textField.tag == 1{
            stateTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
        }
        return false
    }
    
    //Location not found
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
        
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
    
    //Get user's current location
    private func getLocation(){
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {
                
                self.locationManager.requestWhenInUseAuthorization()

            }
            
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
        showTempImage = false
      
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//Various Methods
extension AddVC{
    
    private func configureTextFields(){
        
        self.titleTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
        
        
    }
    private func setTextFieldTags(){
        titleTextField.tag = 0
        cityTextField.tag = 1
        stateTextField.tag = 2
        
    }
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

        let checkCurrentLocation = AddVC.currentLocation
        
        //Always check if current location is added
        if checkCurrentLocation == nil{
            
            alert(message: "Please turn on location services for this app in settings",
                  title: "Location Services Disabled")
            
        }
        
        if let image = chosenImageView.image, let title = titleTextField.text, !title.isEmpty,let city = cityTextField.text, !city.isEmpty, let state = stateTextField.text,!state.isEmpty,addedLocation,showTempImage == false{
            
                    //Create Post
                    let post = Post(image,"\(title)","\(city)","\(state)",User.getName(),checkCurrentLocation!)
                    post.pushPost()
                    //Adding to the following feeds from database instead
//                    //Add to Feed Array
//                    HomeVC.posts.append(post)
//            
//                    //Add to Profile Array
//                    ProfileVC.profilePosts.append(post)
            
                    //Go to home page
                    navigateToHome()
        }else{
            alert(message: "Please check you added a title, city, state, and an image to your post.", title: "Missing Post Information")
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


//Detect tapping when user wants to get out of textfield
extension AddVC
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(AddVC.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
