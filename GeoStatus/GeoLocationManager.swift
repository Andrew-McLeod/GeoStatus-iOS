//
//  GeoLocationManager.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import Alamofire
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

            let regions = GeoRegionStore.sharedInstance.getGeoRegions()
            for region in regions {
                if region.regionType == .Location {
                    let region = region.createRegion() as! CLCircularRegion
                    locationManager.startMonitoringForRegion(region)
                } else {
                    let region = region.createRegion() as! CLBeaconRegion
                    locationManager.startMonitoringForRegion(region)
                    locationManager.startRangingBeaconsInRegion(region)
                }
            }

        }

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()

    }

    func stopMonitoring() {

        locationManager.stopUpdatingLocation()

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

        // Send notification to server
        let geoRegion = GeoRegionStore.sharedInstance.getGeoRegionByName(region.identifier)
        if (geoRegion != nil) {
            sendNotificationToServer(geoRegion!, isArriving: true)

            //NSNotificationCenter.defaultCenter().postNotificationName("GEO-ENTER", object: geoRegion)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName("GEO-ENTER", object: nil, userInfo: ["geo": geoRegion!])
            }
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

        // Send notification to server
        let geoRegion = GeoRegionStore.sharedInstance.getGeoRegionByName(region.identifier)
        print("Region ID: \(region.identifier)")
        if (geoRegion != nil) {
            sendNotificationToServer(geoRegion!, isArriving: false)

            //NSNotificationCenter.defaultCenter().postNotificationName("GEO-EXIT", object: geoRegion)
            NSNotificationCenter.defaultCenter().postNotificationName("GEO-EXIT", object: nil, userInfo: ["geo": geoRegion!])
        }

    }

    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {

    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

        if (beacons.count == 0) { return }

        print("Beacon(s) in range: name=\(region.identifier), count=\(beacons.count), uuid=\(region.proximityUUID.UUIDString)")

        let beacon = beacons[0]
        var proximityString = "Unknown"
        switch beacon.proximity {
        case .Near:
            proximityString = "Near"
        case .Far:
            proximityString = "Far"
        case .Immediate:
            proximityString = ""
        default:
            proximityString = "Unknown"
        }

        let geoRegion = GeoRegionStore.sharedInstance.getGeoRegionByName(region.identifier)
        if (geoRegion != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName("GEO-ENTER", object: nil, userInfo: ["geo": geoRegion!])
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

    func sendNotificationToServer(geoRegion: GeoRegion, isArriving: Bool) {
        
        let parameters = [
            "location": geoRegion.name,
            "device_type": geoRegion.type,
            "verb": isArriving ? "arrived at" : "left",
            "username": "@joe",
            "message": geoRegion.message,
            "url": "No url provided"
        ]
        print("Request: \(parameters)")
        let request = Alamofire.request(.POST, "https://geostatus-production.herokuapp.com/geostatus/", parameters: parameters, encoding: .JSON)
        request.response { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
            print("Sent notification to server, responseCode=\(response?.statusCode)")
        }
    }

    // Helpers 

    func isBeaconReagon(region: CLRegion) -> Bool {
        return region is CLBeaconRegion
    }

}