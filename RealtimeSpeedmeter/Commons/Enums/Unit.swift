//
//  Unit.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/03/05.
//

import Foundation

enum Unit: Int, CaseIterable {
    /// km/h (kphと意味は同じ)
    case kilometerSlashHour
    /// kph (km/hと意味は同じ)
    case kilometerPerHour
    /// mph
    case milePerHour
    /// knot
    case knot
    /// m/s
    case meterSlashSecond
    
    var name: String {
        switch self {
        case .kilometerSlashHour: return "km/h"
        case .kilometerPerHour: return "kph"
        case .milePerHour: return "mph"
        case .knot: return "kn"
        case .meterSlashSecond: return "m/s"
        }
    }
}

extension Double {
    /// 速度の単位変換
    func convertFromMPS(to unit: Unit) -> Double {
        // m/s(mps)から近似値で変換する
        switch unit {
        case .kilometerPerHour, .kilometerSlashHour: return self * 3.6
        case .milePerHour: return self * 2.237
        case .knot: return self * 1.944
        default:
            return self
        }
    }
    
}
