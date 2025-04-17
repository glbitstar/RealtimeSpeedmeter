//
//  GpsSensor.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/28.
//

import CoreLocation
import Combine

final class GpsSensor: NSObject {
    private let locationManager: CLLocationManager = .init()
    let updateLocation = PassthroughSubject<CLLocation, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorize() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
}

extension GpsSensor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
            return
        }
        updateLocation.send(newLocation)
    }
}
