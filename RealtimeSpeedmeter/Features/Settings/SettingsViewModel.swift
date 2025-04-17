//
//  SettingsViewModel.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/02/28.
//

import Foundation

@MainActor final class SettingsViewModel: ObservableObject {
    @MainActor struct ViewState {
        fileprivate(set) var unit: Unit
        fileprivate(set) var maximumSpeed: Int
        fileprivate(set) var colorTheme: ColorTheme
    }
    
    @Published private(set) var state: ViewState
    
    init() {
        state = .init(unit: UserDefaultsClient.unit,
                      maximumSpeed: UserDefaultsClient.maximumSpeed,
                      colorTheme: UserDefaultsClient.colorTheme)
    }
}

extension SettingsViewModel {
    func onChange(unit: Unit) {
        state.unit = unit
        UserDefaultsClient.unit = unit
    }
    
    func onChange(maximumSpeed: Int) {
        state.maximumSpeed = maximumSpeed
        UserDefaultsClient.maximumSpeed = maximumSpeed
    }
    
    func onChange(colorTheme: ColorTheme) {
        state.colorTheme = colorTheme
        UserDefaultsClient.colorTheme = colorTheme
    }
}
