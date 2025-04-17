//
//  SettingsView.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/02/12.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private(set) var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: Binding(
                    get: { viewModel.state.unit.rawValue },
                    set: { newValue in
                        viewModel.onChange(unit: Unit(rawValue: newValue)!)
                    }), label: Text("unit_title")) {
                        ForEach(0 ..< Unit.allCases.count, id: \.self) { num in
                            Text(Unit.allCases[num].name)
                        }
                    }
                
                VStack {
                    HStack {
                        Text("speedmeter_upper_limit_title")
                        Spacer()
                        Text("\(Int(viewModel.state.maximumSpeed)) \(viewModel.state.unit.name)")
                    }
                    HStack {
                        Text("\(Int(Constants.maximumSpeedLowerLimit))")
                        Slider(value: Binding(
                            get: { Double(viewModel.state.maximumSpeed) },
                            set: { newValue in
                                viewModel.onChange(maximumSpeed: Int(newValue))
                            }), in: (Constants.maximumSpeedLowerLimit...Constants.maximumSpeedUpperLimit),
                               step: Constants.maximumSpeedConfigurableInterval)
                        Text("\(Int(Constants.maximumSpeedUpperLimit))")
                    }
                }
                
                Picker(selection: Binding(
                    get: { viewModel.state.colorTheme.rawValue },
                    set: { newValue in
                        viewModel.onChange(colorTheme: ColorTheme(rawValue: newValue)!)
                    }), label: Text("theme_title")) {
                        ForEach(0 ..< ColorTheme.allCases.count, id: \.self) { num in
                            Text(ColorTheme.allCases[num].name)
                        }
                    }
            }
        }
    }
}
