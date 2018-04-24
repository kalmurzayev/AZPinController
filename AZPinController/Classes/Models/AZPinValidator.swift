//
//  AZPinValidator.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation

/// Protocol for entities able to validate input pin code
public protocol AZPinValidating: class {
    /// Any additional validation logic besides basic one, it is called after basic validation
    var additional: ((String) -> Bool)? { get set }
    /// Validates incoming pin string
    ///
    /// - Parameter pin: Pin string
    /// - Returns: Validation result as Bool
    func validate(_ pin: String) -> Bool;
}

open class AZPinValidator: AZPinValidating {
    open var additional: ((String) -> Bool)?;
    private var _pinLength: Int;
    public required init(pinLength: Int = 4) {
        _pinLength = pinLength;
    }
    
    open func validate(_ pin: String) -> Bool {
        var base = pin.count == _pinLength;
        if let logic = additional {
            base = base && logic(pin);
        }
        return base;
    }
}
