//
//  SpeedmeterViewModel.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/23.
//

import Combine
import Foundation
import UIKit

@MainActor final class SpeedmeterViewModel: ObservableObject {
    @MainActor struct ViewState  {
        fileprivate var speedmeterItem = SpeedmeterItem()
        fileprivate(set) var unit: Unit = .kilometerPerHour
        fileprivate(set) var maximumSpeed: Int = 0
        fileprivate(set) var isFirstDisplayed = false
        fileprivate(set) var isSensorActive = true
        
        var accelerationSpeed: Double {
            let speed = speedmeterItem.accelerationSpeed.convertFromMPS(to: unit)
            return abs(speed)
        }
        
        var acceleration: Double {
            speedmeterItem.acceleration
        }
        
        var measurementMethod: String {
            let accelerationText = String(localized: "acceleration_title")
            let gpsText = "GPS"
            return SpeedCalculator.isGpsUnavailable(speedmeterItem.gpsSpeed) ? accelerationText : (accelerationText + " + " + gpsText)
        }
        
        #if DEBUG
            var accelerationState: String {
                return speedmeterItem.accerationState.name
            }
        #endif
    }
    
    @Published private(set) var state: ViewState
    
    private let usecase: SpeedmeterUsecase
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        state = .init()
        let accelerationSensor = AccelerationSensor()
        let gpsSensor = GpsSensor()
        usecase = SpeedmeterUsecase(accelerationSensor: accelerationSensor,
                                    gpsSensor: gpsSensor)
    }
}

extension SpeedmeterViewModel {
    func onAppear() {
        state.unit = UserDefaultsClient.unit
        state.maximumSpeed = UserDefaultsClient.maximumSpeed
        
        usecase.setup()
        usecase.speedmeterItemSubject.receive(on: RunLoop.main).sink { [weak self] speedmeterItem in
            self?.state.speedmeterItem = speedmeterItem
        }.store(in: &cancellables)
        usecase.start()
        
        // Speedmeter画面を表示している間スリープにしない
        UIApplication.shared.isIdleTimerDisabled = true
        
        UserDefaultsClient.incrementNumberOfSpeedmeterDisplayed()
    }
    
    func onDisappear() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func onTapReset() {
        usecase.reset()
    }
    
    #if DEBUG
        func onTapStartStop() {
            if state.isSensorActive {
                usecase.stop()
                state.isSensorActive = false
            } else {
                usecase.start()
                state.isSensorActive = true
            }
        }
    #endif
}
