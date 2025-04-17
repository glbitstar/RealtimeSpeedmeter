//
//  UserDefaultsClient.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/03/09.
//

import Foundation

enum UserDefaultsClient {
    enum IntItem: String {
        case unit
        case maximumSpeed
        case colorTheme
        case numberOfSpeedmeterDisplayed
    }
    
    private static func set(value: Int, forKey item: IntItem) {
        UserDefaults.standard.set(value, forKey: item.rawValue)
    }
    
    private static func integer(forKey item: IntItem) -> Int {
        UserDefaults.standard.integer(forKey: item.rawValue)
    }
}

extension UserDefaultsClient {
    static var unit: Unit {
        get {
            Unit(rawValue: integer(forKey: .unit)) ?? .kilometerPerHour
        }
        set {
            set(value: newValue.rawValue, forKey: .unit)
        }
    }
    
    static var maximumSpeed: Int {
        get {
            // integer(forKey: .maximumSpeed) はdefaultで0を返す
            let value = integer(forKey: .maximumSpeed)
            return value == 0 ? Constants.defaultMaximumSpeed : value
        }
        set {
            set(value: newValue, forKey: .maximumSpeed)
        }
    }
    
    static var colorTheme: ColorTheme {
        get {
            ColorTheme(rawValue: integer(forKey: .colorTheme)) ?? .auto
        }
        set {
            set(value: newValue.rawValue, forKey: .colorTheme)
        }
    }
    
    static var isFirstDisplayed: Bool {
        let numberOfSpeedmeterDisplayed = integer(forKey: .numberOfSpeedmeterDisplayed)
        return numberOfSpeedmeterDisplayed == 0
    }
    
    static func incrementNumberOfSpeedmeterDisplayed() {
        let numberOfSpeedmeterDisplayed = integer(forKey: .numberOfSpeedmeterDisplayed)
        set(value: numberOfSpeedmeterDisplayed + 1,
            forKey: .numberOfSpeedmeterDisplayed)
    }
}
