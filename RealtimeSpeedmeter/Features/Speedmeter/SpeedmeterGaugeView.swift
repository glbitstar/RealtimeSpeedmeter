//
//  GaugePlayground.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/28.
//

import SwiftUI

struct SpeedmeterGaugeView: View {
    let maximumSpeed: Double
    let currentSpeed: Double
    let unitName: String
    let reset: (() -> Void)?
    
    init(maximumSpeed: Double, currentSpeed: Double, unitName: String, reset: (() -> Void)? = nil) {
        self.maximumSpeed = maximumSpeed
        self.currentSpeed = currentSpeed
        self.unitName = unitName
        self.reset = reset
    }
    
    var body: some View {
        Gauge(value: currentSpeed, in: 0...maximumSpeed) {} currentValueLabel: {
            Text("\(String(format: "%.0f", currentSpeed))")
                .bold()
                .font(.system(size: 100))
        }.gaugeStyle(SpeedometerGaugeStyle(unit: unitName, reset: reset))
    }
}

struct SpeedometerGaugeStyle: GaugeStyle {
    private let unit: String
    private let reset: (() -> Void)?
    
    init(unit: String, reset: (() -> Void)? = nil) {
        self.unit = unit
        self.reset = reset
    }
    
    private let leafGreenGradient = LinearGradient(gradient: Gradient(colors: [Color("green"), Color("leaf_green")]),
                                                   startPoint: .trailing,
                                                   endPoint: .leading)
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGray6))
            
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(leafGreenGradient, lineWidth: 20)
                .rotationEffect(.degrees(135))
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 34], dashPhase: 0.0))
                .rotationEffect(.degrees(135))
            
            VStack {
                configuration.currentValueLabel
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                Text(unit)
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                Spacer().frame(height: 16)
                Button {
                    reset?()
                } label: {
                    Text("set to 0")
                }
            }
            
        }
    }
}

struct SpeedmeterGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedmeterGaugeView(maximumSpeed: 100, currentSpeed: 20, unitName: "km/h")
    }
}
