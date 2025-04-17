//
//  RingArray.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/04/11.
//

import Foundation

extension SpeedmeterUsecase {
    struct RingArray {
        let capacity: Int
        private var array: [Double]
        private(set) public var latestIndex: Int = -1
        private(set) public var oldestIndex: Int = 0
        
        var count: Int {
            return (latestIndex - oldestIndex + 1)
        }
        
        var stdev: Double {
            stdev(array)
        }
        
        init(capacity: Int) {
            self.capacity = capacity
            self.array = Array(repeating: 0, count: capacity)
        }
        
        mutating func append(_ value: Double) {
            latestIndex += 1
            array[latestIndex % capacity] = value
            
            if capacity < count {
                oldestIndex += 1
            }
        }
        
        private func stdev(_ array : [Double]) -> Double {
            let length = Double(array.count)
            let average = array.reduce(0, {$0 + $1}) / length
            let sumOfSquaredAverageDiff = array.map { pow($0 - average, 2.0)}.reduce(0, {$0 + $1})
            return sqrt(sumOfSquaredAverageDiff / length)
        }
    }
}
