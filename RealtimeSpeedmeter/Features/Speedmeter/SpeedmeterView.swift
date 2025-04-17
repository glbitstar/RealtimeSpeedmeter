//
//  SpeedmeterView.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/23.
//

import SwiftUI

struct SpeedmeterView: View {
    @ObservedObject private(set) var viewModel: SpeedmeterViewModel
    @State private var showingTutorialAlert = false
    
    init() {
        viewModel = SpeedmeterViewModel()
    }
    
    var body: some View {
        
        let width = UIScreen.main.bounds.width
        
        let contents = VStack {
            #if DEBUG
                HStack {
                    Button {
                        viewModel.onTapStartStop()
                    } label: {
                        Text(viewModel.state.isSensorActive ? "ストップ" : "スタート")
                    }
                    .buttonStyle(.bordered)
                }
                Spacer().frame(height: 32)
            #endif
            Spacer().frame(height: 32)
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Text("0")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(viewModel.state.maximumSpeed)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        
                    }
                }.frame(width: width - 80, height: width - 80, alignment: .bottom)
                SpeedmeterGaugeView(maximumSpeed: Double(viewModel.state.maximumSpeed),
                                    currentSpeed: viewModel.state.accelerationSpeed,
                                    unitName: viewModel.state.unit.name,
                                    reset: { viewModel.onTapReset() })
                .padding()
            }
            
            
            HStack(spacing: 8) {
                VStack(spacing: 8) {
                    Text("acceleration_title")
                        .bold()
                        .font(.title3)
                    Text(String(format: "%.2f G", viewModel.state.acceleration))
                        .font(.body)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2)))
                VStack(spacing: 8) {
                    Text("measurement_method_title")
                        .bold()
                        .font(.title3)
                    Text(viewModel.state.measurementMethod)
                        .font(.body)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2)))
                #if DEBUG
                    VStack(spacing: 8) {
                        Text("加減速")
                            .bold()
                            .font(.title3)
                        Text(viewModel.state.accelerationState)
                            .font(.body)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2)))
                #endif
                
            }
            Spacer()
        }
            .padding()
            .onAppear {
                if UserDefaultsClient.isFirstDisplayed { showingTutorialAlert = true }
                viewModel.onAppear()
            }
            .onDisappear { viewModel.onDisappear() }
        
        return NavigationStack {
            contents
        }.navigationBarTitle("RealtimeSpeedmeter", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView().navigationTitle("Settings")) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .alert("tutorial_title", isPresented: $showingTutorialAlert) {
                Button("OK") { showingTutorialAlert = false }
            } message: {
                Text("tutorial_message")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedmeterView()
            .environment(\.locale, .init(identifier: "ja"))
    }
}
