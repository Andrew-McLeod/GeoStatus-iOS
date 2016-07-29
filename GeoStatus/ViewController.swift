//
//  ViewController.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var locationPermissionBar: UIView!
    @IBOutlet weak var notificationPermissionBar: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var borderView: UIView!

    @IBOutlet weak var gpsLocationLabel: UILabel!
    @IBOutlet weak var beaconLocationLabel: UILabel!

    var currentGeoLocation: GeoRegion?
    var currentGeoBeacon: GeoRegion?

    var currentLocationName: String = "Unknown"
    var currentBeaconName: String = "Unknown"

    var userDragged: Bool = false

    lazy var locationManager: CLLocationManager = {
        let locMgr = CLLocationManager()
        locMgr.delegate = self
        return locMgr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        updatePermissionUI()

        GeoLocationManager.sharedInstance.startMonitoring()

        mapView.showsUserLocation = true
        mapView.delegate = self

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didDragMap))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(geoEntered), name: "GEO-ENTER", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(geoExited), name: "GEO-EXIT", object: nil)

    }

    func geoEntered(notification: NSNotification) {
        if let geoRegion = notification.userInfo?["geo"] as? GeoRegion {
            if geoRegion.regionType == .Beacon {
                beaconLocationLabel.text = geoRegion.name
            } else {
                gpsLocationLabel.text = geoRegion.name
            }
        }
    }

    func geoExited(notification: NSNotification) {
        if let geoRegion = notification.userInfo?["geo"] as? GeoRegion {
            if geoRegion.regionType == .Beacon {
                beaconLocationLabel.text = "Unknown"
            } else {
                gpsLocationLabel.text = "Unknown"
            }
        }
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !userDragged {
            updateUserLocation(userLocation)
        }
    }

    func updateUserLocation(userLocation: MKUserLocation) {
        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        //mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = mapView.frame.size.height / 2.0

        borderView.layer.cornerRadius = borderView.frame.size.height / 2.0
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.darkGrayColor().CGColor
    }

    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        print("DRAGGED")
        self.userDragged = true
    }

    @IBAction func resetUserDragged(sender: AnyObject) {
        self.userDragged = false
        updateUserLocation(mapView.userLocation)
    }

    func updatePermissionUI() {
        notificationPermissionBar.hidden = notificationsEnabled()
        locationPermissionBar.hidden = locationsEnabled()
    }

    func notificationsEnabled() -> Bool {
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if notificationSettings?.types.rawValue == UIUserNotificationType.None.rawValue {
            return false
        } else {
            return true
        }
    }

    func locationsEnabled() -> Bool {
        //GeoLocationManager
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            return true
        case .NotDetermined:
            return false
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            return false // Should probably show a different error in this case
        }
    }

    @IBAction func promptForNotificationPermissions() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        self.performSelector(#selector(ViewController.updatePermissionUI), withObject: nil, afterDelay: 5.0)
    }

    @IBAction func promptForLocationPermissions() {

        locationManager.requestAlwaysAuthorization()

    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        updatePermissionUI()

        // If we just got approved, start monitoring...
        let status = CLLocationManager.authorizationStatus()
        if status == .AuthorizedAlways {
            GeoLocationManager.sharedInstance.startMonitoring()
        }
    }


}

