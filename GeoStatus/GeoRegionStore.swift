//
//  GeoRegionStore.swift
//  GeoStatus
//
//  Created by Andrew McLeod on 7/28/16.
//  Copyright © 2016 Mobile Data Labs. All rights reserved.
//

import Foundation

class GeoRegionStore {

    static var sharedInstance: GeoRegionStore = GeoRegionStore()

    func getGeoRegions() -> [GeoRegion] {

        // TODO: Really store in Realm
        return getAllGeoRegions()

    }

    func getGeoRegionByName(name: String) -> GeoRegion? {
        let regions = getAllGeoRegions()
        for region in regions {
            if region.name == name {
                return region
            }
        }
        return nil
    }

    private func getAllGeoRegions() -> [GeoRegion] {

        // Joe's Home
        let home = GeoRegion()
        home.regionType = .Location
        home.locationRadius.value = 200
        home.locationLatitude.value = 37.7754116
        home.locationLongitude.value = -122.3952237
        home.name = "Home"
        
        let work = GeoRegion()
        work.regionType = .Location
        work.locationRadius.value = 300
        work.locationLatitude.value = 37.7741226
        work.locationLongitude.value = -122.4173377
        work.name = "Work"
        
        let snacks = GeoRegion()
        snacks.regionType = .Beacon
        snacks.beaconUUID = "6665542b-41a1-5e00-931c-6a82db9b78c1"
        snacks.name = "Snacks"

        let stage = GeoRegion()
        stage.regionType = .Beacon
        // TODO: put back in for demo
        stage.beaconUUID = "7b44b47b-52a1-5381-90c2-f09b6838c5d4"
//        bathroom.beaconUUID = "6594f59b-33f9-56e6-8ebf-49ac7c9a0d97"
        stage.name = "the Microsoft Hackathon Stage"
        
        // The birds nest
//        let birdsnest = GeoRegion()
//        birdsnest.regionType = . Beacon
//        bathroom.beaconUUID = "7b44b47b-52a1-5381-90c2-f09b6838c5d4"
//        bathroom.name = "Birds Nest"


        return [home, work, snacks, stage]

    }

}