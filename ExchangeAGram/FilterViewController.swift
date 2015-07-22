//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Kashish Goel on 2015-07-19.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    //variables
    var thisFeedItem:FeedItem!
    var collectionView:UICollectionView!
    let kIntensity = 0.7
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
let layout = UICollectionViewFlowLayout ()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 150)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        self.view.addSubview(collectionView)
        filters = photoFilter()    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //number of pics gonna be displayed
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    //actual pics
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        if cell.imageView.image == nil {
            cell.imageView.image = placeHolderImage
            
            let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
           
            dispatch_async(filterQueue, { () -> Void in
              let filterImage = self.getCachedImage(indexPath.row)
               // let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
        
        
        
        }
        return cell
         }
    //saving the pics to feed view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
     createUIAlertController(indexPath)
        

       
    }
    
    
    //filters function
    func photoFilter () -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
       
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
    
        vignette.setValue(kIntensity*2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity*30, forKey: kCIInputRadiusKey)
    
    return [blur,instant,noir,transfer,unsharpen,monochrome,colorClamp,colorControls,sepia,composite,vignette]
    }
    
    
    //changing image to filtered image
    func filteredImageFromImage (imageData:NSData, filter:CIFilter) -> UIImage {
        let unfilteredImage = CIImage(data:imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
    
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        let finalImage = UIImage(CGImage: cgImage)
return finalImage!
}
    
    //cache funcs
    
    func cacheImage(imageNumber: Int) {
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
       
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        
    }
    func getCachedImage (imageNumber: Int) -> UIImage {
         let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
           var returnedImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)!
        } else {
            self.cacheImage(imageNumber)
            var returnImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)!
        }
        return image
    }
    
    
    //Alert controller
    
    func createUIAlertController (indexPath:NSIndexPath) {
    let alert = UIAlertController(title: "Photo Options", message: "Please Choose one", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
            
            var text:String
            let textField = alert.textFields![0] as! UITextField
            
           
            let photoAction = UIAlertAction(title: "Post Photo To FaceBook With Caption", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
               var text = textField.text
                self.saveFiltersToCoreData(indexPath, caption: text)
                self.shareToFacebook(indexPath, caption: text)
            })
            alert.addAction(photoAction)
            
            let saveFilterAction = UIAlertAction(title: "Save without uploading to Facebook", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                var text = textField.text
                self.saveFiltersToCoreData(indexPath, caption: text)
                
            })
            alert.addAction(saveFilterAction)
            
            let cancelAction = UIAlertAction(title: "Select another filter", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                
            })
            alert.addAction(cancelAction)

            self.presentViewController(alert, animated: false, completion: nil)
        }
    }
    
    //saves filters so we can return to the main screen to present the filtered image
    func saveFiltersToCoreData (indexPath:NSIndexPath, caption:String) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        self.thisFeedItem.caption = caption
        self.thisFeedItem.filtered = true 
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
//see facebook developer
    func shareToFacebook(indexPath: NSIndexPath, caption: String) {
        
        // If not logged into Facebook, alert user
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            self.quickAlert("Warning", message: "You do not appear to be logged in to Facebook.")
        }
        else
        {
            // Get the image data 4 the full size filtered image
            let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: filters[indexPath.row])
            let imageData: NSData = UIImageJPEGRepresentation(filterImage, 1.0)
            
            // Build a Facebook Graph request to add a photo w description
            let params = [ "data" : imageData, "name" : caption ]
            var fbGraphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params, HTTPMethod: "POST")
            // Create a Facebook Graph connection and add the request object with callback handler
            var fbConnection = FBSDKGraphRequestConnection()
            fbConnection.addRequest(fbGraphRequest, completionHandler: { (connection, result, error) in
                if (error != nil)
                {
                    println( "\(error.localizedDescription)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Error", message: "Problem posting photo.\r\nError description: \(error.localizedDescription)")
                    }
                }
                if (result != nil)
                { println( "\(result)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Success", message: "Photo posted to Facebook." )
                        
                    }
                }
            } )
            // Execute the Graph request
            fbConnection.start()
        }
    }
    
    //helper func
       func quickAlert(header: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(closeAction)
        
        UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
   
}