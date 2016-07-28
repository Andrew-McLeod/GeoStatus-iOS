//
//  GeoLocationManager.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

class GeoLocationManager: NSObject, CLLocationManagerDelegate {

    // Singleton this sucka!
    static var sharedInstance: GeoLocationManager = GeoLocationManager()

    lazy var locationManager: CLLocationManager = {
        let locMgr = CLLocationManager()
        locMgr.delegate = self
        return locMgr
    }()

    func startMonitoring() {

        let status = CLLocationManager.authorizationStatus()
        if status == .AuthorizedAlways {
            // Register geofences, beacons, etc
        }

    }

    func stopMonitoring() {

    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {

        if let beaconRegion = region as? CLBeaconRegion {
            let message = String(format: "Beacon region ENTERED: %@", beaconRegion.identifier)
            sendLocalNotification(message)
        }

        if let circleRegion = region as? CLCircularRegion {
            let message = String(format: "Location region ENTERED: %@", circleRegion.identifier)
            sendLocalNotification(message)
        }

    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {

        if let beaconRegion = region as? CLBeaconRegion {
            let message = String(format: "Beacon region EXITED: %@", beaconRegion.identifier)
            sendLocalNotification(message)
        }

        if let circleRegion = region as? CLCircularRegion {
            let message = String(format: "Location region EXITED: %@", circleRegion.identifier)
            sendLocalNotification(message)
        }

    }

    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {

    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

    }

    func sendLocalNotification(message: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate().dateByAddingTimeInterval(0.3)
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    // Helpers 

    func isBeaconReagon(region: CLRegion) -> Bool {
        return region is CLBeaconRegion
    }

}