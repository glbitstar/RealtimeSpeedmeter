//
//  AccelerationState.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/10.
//

enum AccelerationState {
    /// 加速中
    case accelerating
    /// 減速中
    case decelerating
    /// 巡航中・停止中
    case stay
    
    var name: String {
        switch self {
        case .accelerating: return "Acc"
        case .decelerating: return "Dec"
        case .stay: return "Stay"
        }
    }
}
