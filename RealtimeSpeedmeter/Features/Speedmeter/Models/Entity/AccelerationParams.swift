//
//  AccelerationParams.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/11.
//

struct AccelerationParams {
    let acceleration: Double
    let speed: Double
    let accelerationState: AccelerationState
    
    init() {
        self.acceleration = 0
        self.speed = 0
        self.accelerationState = .stay
    }
    
    init(acceleration: Double, speed: Double, accelerationState: AccelerationState) {
        self.acceleration = acceleration
        self.speed = speed
        self.accelerationState = accelerationState
    }
}
