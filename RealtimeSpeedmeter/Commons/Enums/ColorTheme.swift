//
//  ColorTheme.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/05.
//

import SwiftUI

enum ColorTheme: Int, CaseIterable {
    /// OS依存
    case auto
    /// ライトテーマ
    case light
    /// ダークテーマ
    case dark
    
    var name: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var scheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return ColorScheme.light
        case .dark: return ColorScheme.dark
        }
    }
}
