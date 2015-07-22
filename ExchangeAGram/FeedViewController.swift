//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Kashish Goel on 2015-07-16.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDataSource, CLLocationManagerDelegate  {

    @IBOutlet weak var collectionView: UICollectionView!
    var feedArray: [AnyObject] = []
    var locationManager: CLLocationManager!
    //ViewDidLoad
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImage = UIImage(named: "AutumnBackground")
        self.view.backgroundColor = UIColor(patternImage: bgImage!)
        
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ViewDidLoadAbove
    //
    //
   

    //Camera button
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
    
            
            else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                
                var photoLibraryController = UIImagePickerController()
                photoLibraryController.delegate = self
                photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                let mediaTypes:[AnyObject] = [kUTTypeImage]
                photoLibraryController.mediaTypes = mediaTypes
                photoLibraryController.allowsEditing = false
                
                self.presentViewController(photoLibraryController, animated: true, completion: nil)
            }        else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo Library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }} 
        
        
    //UIIMagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbNail = thumbNailData
        feedItem.latitude = locationManager.location.coordinate.latitude
        feedItem.longitude = locationManager.location.coordinate.longitude
        let UUID = NSUUID().UUIDString
        feedItem.uniqueID = UUID
        feedItem.filtered = false
        
        
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell
        let thisItem = feedArray[indexPath.row] as! FeedItem
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        if thisItem.filtered == true {
        let returnedImage = UIImage(data: thisItem.image)
            let image = UIImage(CGImage: returnedImage!.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
        }
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        var filterVC = FilterViewController ()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
        
        
    }
    
    //updates the feedview when didselect is clicked in filter view
    override func viewDidAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!
        collectionView.reloadData()
    }

    
    @IBAction func profileButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
   
    
    //location stuff
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locations = \(locations)")
    }
    
    
    
    
}
