//
//  ViewController.swift
//  Clean Up Hawaii
//
//  Created by Zachary Kline on 8/6/18.
//

import UIKit
import Foundation

class HomeVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {


    @IBOutlet var mainCollectionView: UICollectionView!
    
    static var imageArray : [UIImage] = []
    
    static var locationArray : [String] = []
    
    let actionSheet = UIAlertController(title: "Options", message: "Please select an option", preferredStyle: .actionSheet)
    
    var loadActionsOnce = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //Assign Date to collection view
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
 
    }
    
    //Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return HomeVC.imageArray.count
        
    }
    
    //Give each cell its properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionViewCell
        
        cell.imageView.image = HomeVC.imageArray[indexPath.row]
        
        cell.locationLabel.text = HomeVC.locationArray[indexPath.row]
        
        cell.layer.borderColor = UIColor.darkGray.cgColor
        
        cell.layer.borderWidth = 0.5
        
        return cell
        
    }
    
    //Select Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
      //  cell?.layer.borderColor = UIColor.green.cgColor
        
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
    
   
    //TODO: Update clean feed after somebody adds somthing
    override func viewWillAppear(_ animated: Bool) {
        
        //TODO: Update the UI so it shows the persons new additon
        
       
    }
    
    //Don't think we will need this if we our using databases to pull the info
    /*
    static func saveCells(){
        
       UserDefaults.standard.set(HomeVC.imageArray, forKey: "IMAGE")
       UserDefaults.standard.set(HomeVC.locationArray, forKey: "LOCATION")

    }
    
    
    static func loadImages() -> ([UIImage]){
        
        return UserDefaults.standard.array(forKey: "IMAGE") as? [UIImage] ?? [UIImage]()
    
        
    }
    
    static func loadLocationText() -> ([String]){
        
        return UserDefaults.standard.array(forKey: "LOCATION") as? [String] ?? [String]()
        
        
    }*/
    
    //MARK: Give Location and Take off feed their actions
    private func addActions(title name: String){
        

            actionSheet.addAction(UIAlertAction(title: "\(name)", style: .default, handler: {(action:UIAlertAction) in
            
            if name == "Location"{
              
                //TODO: Present apple maps and location of the trash
              //  self.present(imagePickerController,animated: true,completion: nil)
   
                
            }else{
                
                print("You clicked take off feed")
                //TODO: Take cell of feed
               
                
               
           
            }
            
        }))
        
        
        
    }

    



}


