//
//  CSVLogger+Extension.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/02/22.
//

import CoreMotion

extension CSVLogger {
    func setRealtimeSpeedMeterLogHeader() {
        set(header: ["time", "ax", "ay", "az", "roll", "pitch", "HorizontalAcc", "SmoothedAcc", "SpeedAcc", "StoppingCounter", "SpeedGps", "Latitude", "Longitude", "SpeedGpsAccuracy", "LocationGpsAccuracy"])
    }
    
    func appendBody(motion: CMDeviceMotion,
                    horizontalAcceleration: Double,
                    acceleration: Double,
                    accelerationSpeed: Double,
                    stoppingCounter: Int,
                    gpsParams: GpsParams
    ) {
        let date = Date().description
        let ax = String(motion.userAcceleration.x)
        let ay = String(motion.userAcceleration.y)
        let az = String(motion.userAcceleration.z)
        let roll = String(motion.attitude.roll)
        let pitch = String(motion.attitude.pitch)
        let speedGps = String(gpsParams.speed)
        let latitude = String(gpsParams.location.lat)
        let longitude = String(gpsParams.location.lng)
        let speedGpsAccuracy = String(gpsParams.speedAccuracy)
        let locationGpsAccuracy = String(gpsParams.locationAccuracy)
        
        let log: [String] = [date,
                             ax,
                             ay,
                             az,
                             roll,
                             pitch,
                             String(horizontalAcceleration),
                             String(acceleration),
                             String(accelerationSpeed),
                             String(stoppingCounter),
                             speedGps,
                             latitude,
                             longitude,
                             speedGpsAccuracy,
                             locationGpsAccuracy]
        
        appendBody(row: log)
    }
}
