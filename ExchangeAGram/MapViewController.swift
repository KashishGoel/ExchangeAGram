//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Kashish Goel on 2015-07-22.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        var error:NSError?
        let itemArray = context.executeFetchRequest(request, error: &error)
        if itemArray?.count > 0 {
            for item in itemArray! as! [FeedItem]{
            let location = CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude))
           let span  = MKCoordinateSpanMake(0.06, 0.06)
                let region = MKCoordinateRegionMake(location, span)
               mapView.setRegion(region, animated: false)
                let annotation = MKPointAnnotation ()
                annotation.coordinate = location
                annotation.title = item.caption
                mapView.addAnnotation(annotation)
            }
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
