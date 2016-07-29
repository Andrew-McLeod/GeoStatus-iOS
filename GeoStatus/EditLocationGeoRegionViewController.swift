//
//  EditLocationGeoRegionViewController.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class EditLocationGeoRegionViewController: UIViewController, CLLocationManagerDelegate {

    var shouldFollow: Bool = true

    @IBOutlet weak var map: MKMapView!

    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
        }
    }
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
        }
    }

    override func viewDidLoad() {
        map.showsUserLocation = true


//        let camera = MKMapCamera(lookingAtCenterCoordinate: map.userLocation.coordinate, fromDistance: <#T##CLLocationDistance#>, pitch: <#T##CGFloat#>, heading: <#T##CLLocationDirection#>)
//        map.setCamera(<#T##camera: MKMapCamera##MKMapCamera#>, animated: <#T##Bool#>)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

}
