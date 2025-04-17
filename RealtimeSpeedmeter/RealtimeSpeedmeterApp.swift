//
//  RealtimeSpeedmeterApp.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/23.
//

import SwiftUI

@main
struct RealtimeSpeedmeterApp: App {
    @AppStorage(UserDefaultsClient.IntItem.colorTheme.rawValue) var colorTheme: ColorTheme?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SpeedmeterView()
                    .preferredColorScheme(colorTheme?.scheme)
            }
        }
    }
}
