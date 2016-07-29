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

            // TODO: Loop Realm?

            if let uuid = NSUUID(UUIDString: "6665542b-41a1-5e00-931c-6a82db9b78c1") {
                let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
                locationManager.startMonitoringForRegion(beaconRegion)
                locationManager.startRangingBeaconsInRegion(beaconRegion)
            }

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

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if (beacons.count == 0) { return }

        let beacon = beacons[0]
        var proximityString = "Unknown"
        switch beacon.proximity {
        case .Near:
            proximityString = "Near"
        case .Far:
            proximityString = "Far"
        case .Immediate:
            proximityString = "Immediate"
        default:
            proximityString = "Unknown"
        }

        let message = String(format: "Beacon RANGED: %f, %f", proximityString, beacon.accuracy)
        print("BEACON RANGED!  proximity: %f, accuracy: %@", proximityString, beacon.accuracy)
        sendLocalNotification(message)
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