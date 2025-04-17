//
//  SpeedmeterItem.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/03/06.
//

import Foundation

struct SpeedmeterItem {
    let acceleration: Double
    let accelerationSpeed: Double
    let gpsSpeed: Double
    let gpsAccuracy: Double
    let accerationState: AccelerationState
    
    init() {
        self.init(acceleration: 0, accelerationSpeed: 0, gpsSpeed: 0, gpsAccuracy: 0, accerationState: .stay)
    }
    
    init(acceleration: Double, accelerationSpeed: Double, gpsSpeed: Double, gpsAccuracy: Double, accerationState: AccelerationState) {
        self.acceleration = acceleration
        self.accelerationSpeed = accelerationSpeed
        self.gpsSpeed = gpsSpeed
        self.gpsAccuracy = gpsAccuracy
        self.accerationState = accerationState
    }
}
