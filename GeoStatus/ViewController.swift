//
//  ViewController.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationPermissionBar: UIView!
    @IBOutlet weak var notificationPermissionBar: UIView!

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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

