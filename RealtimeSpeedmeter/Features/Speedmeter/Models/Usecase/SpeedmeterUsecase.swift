//
//  SpeedmeterUsecase.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/02/22.
//

import Combine
import Foundation
import CoreLocation
import CoreMotion

final class SpeedmeterUsecase {
    /// ViewModelで購読するプロパティ
    let speedmeterItemSubject = PassthroughSubject<SpeedmeterItem, Never>()
    
    private let accelerationSensor: AccelerationSensor
    private let gpsSensor: GpsSensor
    
    init(accelerationSensor: AccelerationSensor, gpsSensor: GpsSensor) {
        self.accelerationSensor = accelerationSensor
        self.gpsSensor = gpsSensor
    }
    
    // 計算用プロパティ
    private let accelerationParamsSubject = CurrentValueSubject<AccelerationParams, Never>(AccelerationParams())
    private let gpsParamsSubject = CurrentValueSubject<GpsParams, Never>(GpsParams(cllocation: CLLocation()))
    /// 標準偏差による停止判定用の配列
    private var unsmoothedAccelerationRingArray = RingArray(capacity: Constants.stoppingAccelerationsCapacity)
    /// 定めた閾値を超えたら停止判定する
    private var stoppingCounter: Int = 0
    // 定めた閾値を超えたカウンタをaccerationStateにセットする
    private var stayingCounter: Int = 0
    private var accerationCounter: Int = 0
    private var decelerationCounter: Int = 0
    private var updatedDate = Date()
    
    #if DEBUG
        private let csvLogger = CSVLogger()
    #endif
    private var cancellables: Set<AnyCancellable> = []
}

extension SpeedmeterUsecase {
    func setup() {
        gpsSensor.requestAuthorize()
        
        gpsSensor.updateLocation.receive(on: RunLoop.main).sink(receiveValue: { [weak self] location in
            self?.gpsParamsSubject.send(GpsParams(cllocation: location))
        }).store(in: &cancellables)
        
        accelerationSensor.updateMotion.receive(on: RunLoop.main).sink(receiveValue: { [weak self] motion in
            self?.updateSpeedmeterItem(with: motion)
        }).store(in: &cancellables)
        
        accelerationParamsSubject.combineLatest(gpsParamsSubject)
            .sink { [weak self] (accParam, gpsParams) in
                self?.speedmeterItemSubject.send(SpeedmeterItem(
                    acceleration: accParam.acceleration,
                    accelerationSpeed: accParam.speed,
                    gpsSpeed: gpsParams.speed,
                    gpsAccuracy: gpsParams.locationAccuracy,
                    accerationState: accParam.accelerationState))
            }.store(in: &cancellables)
        
        #if DEBUG
            csvLogger.setRealtimeSpeedMeterLogHeader()
        #endif
    }
    
    func start() {
        accelerationSensor.start(delta: 1 / Constants.fps)
        gpsSensor.start()
    }
    
    func stop() {
        reset()
        accelerationSensor.stop()
        gpsSensor.stop()
        #if DEBUG
            csvLogger.save()
            csvLogger.clearBody()
        #endif
    }
    
    func reset() {
        let acceleration = self.accelerationParamsSubject.value.acceleration
        self.accelerationParamsSubject.send(AccelerationParams(acceleration: acceleration,
                                                               speed: 0,
                                                               accelerationState: .stay))
        stoppingCounter = 0
        accerationCounter = 0
        decelerationCounter = 0
        stayingCounter = 0
    }
}

private extension SpeedmeterUsecase {
    /// 加速度やGPSセンサの値を元にSpeedmeterItemを更新する
    func updateSpeedmeterItem(with motion: CMDeviceMotion) {
        let elapsedTime = Date().timeIntervalSince(updatedDate)
        
        let horizontalAcceleration = SpeedCalculator.calculateHorizontalAcceleration(motion)
        let acceleration = SpeedCalculator.smooth(current: horizontalAcceleration,
                                                  previous: accelerationParamsSubject.value.acceleration)
        // 停止判定
        unsmoothedAccelerationRingArray.append(horizontalAcceleration)
        let isStopping = SpeedCalculator.isStopping(accelerationStdev: unsmoothedAccelerationRingArray.stdev)
        stoppingCounter = isStopping ? stoppingCounter + 1 : 0
        
        // 速度の計算
        let accelerationSpeed = SpeedCalculator.calculateSpeed(previousSpeed: accelerationParamsSubject.value.speed,
                                                               acceleration: acceleration,
                                                               delta: elapsedTime,
                                                               stoppingCounter: stoppingCounter)
        // 加減速の判定
        let accerationState = decideAccelerationState(acceleration)
        // 加減速の状態(accerationState)を元にACC速度とGPS速度を組み合わせて最終的な速度を決定
        let combinedSpeed = SpeedCalculator.combineSpeed(accelerationSpeed: accelerationSpeed,
                                                   gpsSpeed: gpsParamsSubject.value.speed,
                                                   accerationState: accerationState)
        
        accelerationParamsSubject.send(AccelerationParams(
            acceleration: acceleration,
            speed: combinedSpeed,
            accelerationState: accerationState))
        
        #if DEBUG
            csvLogger.appendBody(motion: motion,
                                 horizontalAcceleration: horizontalAcceleration,
                                 acceleration: acceleration,
                                 accelerationSpeed: accelerationSpeed,
                                 stoppingCounter: stoppingCounter,
                                 gpsParams: gpsParamsSubject.value)
        #endif
        updatedDate = Date()
    }
    
    /// 加速中・減速中・巡航中かの判定
    private func decideAccelerationState(_ acceleration: Double) -> AccelerationState {
        // 加速・減速・巡航状態が指定したフレーム続くことで初めてステートが変化する
        // これにより、ステートが無用に振動するのを防ぐ
        if acceleration > Constants.accelerationStateChangeThresh {
            if accerationCounter > Int(Constants.fps * Constants.stateHoldTime) {
                return .accelerating
            }
            accerationCounter += 1
            decelerationCounter = 0
            stayingCounter = 0
        } else if acceleration < -1 * Constants.accelerationStateChangeThresh {
            if decelerationCounter > Int(Constants.fps * Constants.stateHoldTime) {
                return .decelerating
            }
            accerationCounter = 0
            decelerationCounter += 1
            stayingCounter = 0
        } else {
            if stayingCounter > Int(Constants.fps * Constants.stateHoldTime) {
                return .stay
            }
            accerationCounter = 0
            decelerationCounter = 0
            stayingCounter += 1
        }
        // Counterが閾値を超えるまでは元のStateを返す
        return accelerationParamsSubject.value.accelerationState
    }
}
