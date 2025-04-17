//
//  GpsParams.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/11.
//

import CoreLocation

struct GpsParams {
    let speed: Double
    let location: (lat: Double, lng: Double)
    let speedAccuracy: Double
    let locationAccuracy: Double
    
    init(cllocation: CLLocation) {
        self.speed = cllocation.speed
        self.location = (cllocation.coordinate.latitude, cllocation.coordinate.longitude)
        self.speedAccuracy = cllocation.speedAccuracy
        self.locationAccuracy = cllocation.horizontalAccuracy
    }
}
