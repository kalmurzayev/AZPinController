//
//  Array+AZPin.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
extension Array where Element: FloatingPoint {
    /// Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}
