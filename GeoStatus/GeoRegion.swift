//
//  GeoRegion.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import CoreLocation
import Foundation
import RealmSwift

class GeoRegion: Object {

    dynamic var name: String = ""
    dynamic var message: String = ""
    dynamic var type: String = "location"
    let locationLongitude = RealmOptional<Float>()
    let locationLatitude = RealmOptional<Float>()
    let locationRadius = RealmOptional<Float>()
    dynamic var beaconUUID: String?
    dynamic var verb: String = ""
    dynamic var url: String = ""

    override static func ignoredProperties() -> [String] {
        return ["regionType"]
    }

    var regionType: GeoRegionType {
        get {
            if self.type == "beacon" {
                return .Beacon
            } else {
                return .Location
            }
        }
        set {
            switch newValue {
            case .Beacon:
                self.type = "beacon"
            case .Location:
                self.type = "location"
            }
        }
    }

    func createRegion() -> CLRegion {
        if self.regionType == .Beacon {
            let uuid = NSUUID(UUIDString: self.beaconUUID!)!
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: self.name)
            return beaconRegion
        } else {
            let coordinate = CLLocationCoordinate2DMake(Double(self.locationLatitude.value!), Double(self.locationLongitude.value!))
            let circularRegion = CLCircularRegion(center: coordinate, radius: Double(self.locationRadius.value!), identifier: self.name)
            return circularRegion
        }
    }

}

enum GeoRegionType {
    case Beacon
    case Location
}