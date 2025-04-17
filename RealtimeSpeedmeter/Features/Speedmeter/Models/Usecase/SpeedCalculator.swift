//
//  SpeedCalculator.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/24.
//

import Foundation
import CoreMotion

enum SpeedCalculator {
    /// 3軸成分から水平1軸成分のみを取り出す
    static func calculateHorizontalAcceleration(_ motion: CMDeviceMotion) -> Double {
        // 単位を度数に変換
        let rollDeg = motion.attitude.roll * 180.0 / Double.pi
        let pitchDeg = motion.attitude.pitch * 180.0 / Double.pi
        // -90度から+90度の範囲となるよう正規化
        let roll90: Double
        if (rollDeg > 90.0) { // 傾きが90度を上回っている場合, 超えている分を90から引く
            roll90 = 90.0 - (rollDeg - 90.0)
        } else if (rollDeg < -90) {
            roll90 = -90.0 - (rollDeg + 90.0)
        } else {
            roll90 = rollDeg
        }
        let pitch90 = pitchDeg // pitchは元から-90から+90の範囲になっているのでそのまま
        
        let rollRadian = roll90 / (180.0 / Double.pi)
        let pitchRadian = pitch90 / (180.0 / Double.pi)
        
        let xWeight = cos(rollRadian)
        let yWeight = cos(pitchRadian)
        let zWeight = abs(rollRadian) > abs(pitchRadian) ? abs(sin(rollRadian)) : abs(sin(pitchRadian))
        
        let xHorizontal = motion.userAcceleration.x * xWeight
        let yHorizontal = motion.userAcceleration.y * yWeight
        let zHorizontal = motion.userAcceleration.z * zWeight
        
        // 三平方の定理で水平方向成分を合成する
        let horizontalComponent = sqrt(pow(xHorizontal, 2) +
                                       pow(yHorizontal, 2) +
                                       pow(zHorizontal, 2))
        // 方向を考慮する (z軸方向で考慮)
        return horizontalComponent * (motion.userAcceleration.z > 0 ? 1 : -1)
    }
    
    /// 簡易平滑化フィルタ (ローパスフィルタ)
    static func smooth(current: Double, previous: Double) -> Double {
        current * 0.2 + previous * 0.8
    }
    
    /// 停止判定込みで現在の速度を計算する
    static func calculateSpeed(previousSpeed: Double, acceleration: Double, delta: Double, stoppingCounter: Int) -> Double {
        switch stoppingCounter {
        case 0:
            return calculateCurrentSpeed(previousSpeed, acceleration, delta)
        case 1..<Constants.stoppingResetIntervalCount:
            return previousSpeed
        default:
            return 0
        }
        
        /// 加速度を元に現在の速度を計算する
        func calculateCurrentSpeed(_ previousSpeed: Double, _ acceleration: Double, _ delta: Double) -> Double {
            let gravitationalAcceleration = 9.80665
            return previousSpeed + (acceleration * delta * gravitationalAcceleration)
        }
    }
    
    /// 加減速状態を元に、ACC速度(加速度から計算した速度)と、GPS速度を組み合わせる
    static func combineSpeed(accelerationSpeed: Double, gpsSpeed: Double, accerationState: AccelerationState) -> Double {
        // GPS速度が利用できない場合はACC速度(加速度から算出した速度)を使う
        if isGpsUnavailable(gpsSpeed) { return accelerationSpeed }
        
        // GPSも利用できる場合、
        // 加速中はGPS速度とACC速度の大きい方、減速中は小さい方の速度を採用する
        // 加減速していない場合(stay時)はGPS速度を使う
        switch accerationState {
        case .accelerating:
            return max(accelerationSpeed, gpsSpeed)
        case .decelerating:
            return min(accelerationSpeed, gpsSpeed)
        case .stay:
            return gpsSpeed
        }
    }
}

extension SpeedCalculator {
    static func isGpsUnavailable(_ speedGps: Double) -> Bool {
        return speedGps == -1
    }
    
    /// 端末の動きが止まっているか (加速度の標準偏差≒0で停止判断)
    /// センサの特性上運動が停止しても加速度はすぐには0にならないが、振動は収まるため標準偏差の値を使って判定する
    static func isStopping(accelerationStdev: Double) -> Bool {
        return accelerationStdev < Constants.stoppingStdevThresh
    }
}
