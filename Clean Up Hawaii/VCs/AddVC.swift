//
//  AddVC.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import MapKit
import CoreLocation


//Still working on this
class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

class AddVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    //Outlets and variables
    @IBOutlet var chosenImageView: UIImageView!
    
    let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
    
    var loadActionsOnce = true
    
    var locationManager = CLLocationManager()

    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        mapView.isHidden = true
        
        
        
        

       
    }


    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude,
                                                                       longitude: locations[0].coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    

    @IBAction func pickImagePressed(_ sender: Any) {

        //Create and present action sheet
        //Add actions once so they don't replicate
        if loadActionsOnce{
            
            loadActionsOnce = false
            
            addActions(title: "Camera")
            addActions(title: "Photo Library")
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    

    @IBAction func addPostPressed(_ sender: Any) {
        
        let chosenImage = chosenImageView.image
        
        if chosenImage != nil{
            
            //TODO: Shift everythign to the rigHT ONE AND ADD new post at top of feed
            HomeVC.imageArray.append(chosenImage!)
            HomeVC.locationArray.append("This is where your text goes")
            navigateToHome()
            
            
            
        }else{
            
            alert(message: "Please select an image before posting to feed", title: "No Image Selected")
        }
 
    }
        
    //Action Sheet for Selecting an Image
    private func addActions(title name: String){
        
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        
        actionSheet.addAction(UIAlertAction(title: "\(name)", style: .default, handler: {(action:UIAlertAction) in
            
            if name == "Camera"{
                
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController,animated: true,completion: nil)
                }else{
                    
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
        
        mapView.isHidden = false
        
        //This will locate their current location on apple maps
        //This does ask permission before locating User (Asking permission is done in Info.plst)
        //TODO: If they choose no for location, need to make sure we tell them where to go to turn it on
        
        if CLLocationManager.locationServicesEnabled() == true {
    
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                
                self.locationManager.requestWhenInUseAuthorization()
            }
            
            self.locationManager.desiredAccuracy = 1.0
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            
        } else {
            alert(message: "Please go to your settings and turn on Location Services",
                  title: "Turn On Location Services")
        }
        
        
    }
    
    //Call to Segue to homepage
    private func navigateToHome(){
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let navigationVC = mainStoryboard.instantiateViewController(withIdentifier: "MainNavVC") as? MainNavVC else{

            return
            
        }
        
        present(navigationVC, animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        chosenImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    //Push alert to user
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
