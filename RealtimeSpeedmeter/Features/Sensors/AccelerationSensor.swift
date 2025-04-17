//
//  AccelerationSensor.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/23.
//

import CoreMotion
import Combine

final class AccelerationSensor {
    private let motionManager: CMMotionManager
    let updateMotion = PassthroughSubject<CMDeviceMotion, Never>()
    
    init() {
        motionManager = CMMotionManager()
    }
    
    func start(delta: Double) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = delta // sec
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [weak self] (motion: CMDeviceMotion?, error: Error?) in
                guard let motion = motion else { return }
                self?.updateMotion.send(motion)
            })
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
