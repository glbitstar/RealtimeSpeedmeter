//
//  Constants.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/04.
//

enum Constants {
    // MARK: - Speed Measurement Param
    /// 加速度計測の間隔
    static let fps: Double = 100
    /// 加速度の標準偏差の状態が stoppingResetInterval 秒間続くと速度をリセットする(ドリフト防止)
    static let stoppingResetInterval = 1.0
    static var stoppingResetIntervalCount: Int { Int(fps * stoppingResetInterval) }
    /// 加速度の標準偏差がこの値を下回っていれば停止状態と判定
    static let stoppingStdevThresh = 0.01
    /// 標準偏差による停止判定用の配列の要素数
    static let stoppingAccelerationsCapacity = 10
    /// 加速度が accelerationStateChangeThresh を上(下)回っている状態がstateHoldTime秒続くと、加減速中(Stay中)と判定する
    static let accelerationStateChangeThresh = 0.05
    static let stateHoldTime = 0.2
    
    // MARK: - Settings Param
    static let defaultMaximumSpeed = 30
    static let maximumSpeedUpperLimit: Double = 500
    static let maximumSpeedLowerLimit: Double = 20
    static let maximumSpeedConfigurableInterval: Double = 10
}
