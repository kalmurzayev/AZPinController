//
//  AZPinText.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation

/// Object containing PIN code value, with optional capacity property
class AZPinText: NSObject {
    private var _mutableString = NSMutableString();
    private var _capacity: Int;
    var value: String {
        return String(_mutableString);
    }
    var length: Int {
        return _mutableString.length;
    }
    required init(capacity: Int) {
        _capacity = capacity;
        super.init();
    }
    
    /// Adds character to container, if capacity allows
    ///
    /// - Parameter char: input char
    func add(_ char: String) {
        if self.length >= _capacity { return }
        _mutableString.append(char);
    }
    
    /// Deletes last digit from pin code
    func delete() {
        if self.length < 1 { return }
        _mutableString.deleteCharacters(in: NSRange(location: self.length - 1, length: 1));
    }
    
    /// Flushes container
    func reset() {
        _mutableString = NSMutableString();
    }
}
