//
//  AZPinField.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit;

class AZPinField: UIView {
    static let heightDefault: CGFloat = 16;
    static let numberOfOscillations: Int = 5;
    static let oscillationAmp: CGFloat = 30;
    static let oscillationDuration: TimeInterval = 0.05;
    var fillColor: UIColor? {
        didSet {
            if self.fillColor == nil { return }
            self._entryList.forEach {
                $0.fillColor = self.fillColor!;
            }
        }
    };
    var successColor: UIColor? {
        didSet {
            if self.successColor == nil { return }
            self._entryList.forEach {
                $0.successColor = self.successColor!;
            }
        }
    };
    var errorColor: UIColor? {
        didSet {
            if self.errorColor == nil { return }
            self._entryList.forEach {
                $0.errorColor = self.errorColor!;
            }
        }
    };
    var fillAnimate: Bool = true {
        didSet {
            self._entryList.forEach {
                $0.fillAnimate = self.fillAnimate;
            }
        }
    };
    private var _numberOfEntries: Int = 4;
    private var _entryList: [AZPinFieldEntry] = [];
    private var _filledCount: Int = 0;
    private var _numOfShakes: Int = 0;
    private var _shakeDirection: Int = -1;
    private var _shakeAmp: CGFloat = 0;
    // MARK: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    convenience init(pinLength: Int) {
        self.init(frame: CGRect.zero);
        self._numberOfEntries = pinLength;
        self.initiateViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /// Fills the next Field Entry and increments filledCount
    func addEntry() {
        if self._filledCount >= self._numberOfEntries { return }
        self._entryList[self._filledCount].fill();
        self._filledCount += 1;
    }
    
    /// Unfills the current Field Entry and decrements filledCount
    func deleteEntry() {
        if self._filledCount <= 0 { return }
        self._filledCount -= 1;
        self._entryList[self._filledCount].reset();
    }
    
    /// Resets the whole EntryField
    func reset() {
        self._filledCount = 0;
        self._entryList.forEach({ $0.reset() });
    }
    
    /// Fills all entries in success Color
    func fillSuccess() {
        self._entryList.forEach { $0.fillSuccess() };
    }
    
    /// Fills all entries in error color
    func fillError() {
        self._entryList.forEach { $0.fillError() };
    }
    
    /// trembles field entries while filling them in error color
    func trembleError() {
        self.fillError();
        self.trembleView(amplitude: 30, completion: {  self.reset() });
    }
    
    /// Initiates itself and sets layout constraints to child FieldEntries
    private func initiateViews() {
        self.snp.makeConstraints({
            $0.height.equalTo(AZPinField.heightDefault);
        });
        
        let blockWidth: CGFloat = (2 * CGFloat(self._numberOfEntries) - 1) * AZPinField.heightDefault;
        self.snp.makeConstraints({
            $0.width.equalTo(blockWidth);
        });
        for i in 0...self._numberOfEntries - 1 {
            let entry = AZPinFieldEntry();
            self.addSubview(entry);
            self._entryList.append(entry);
            entry.snp.makeConstraints({
                $0.leading.equalTo(CGFloat(i) * 2 * AZPinField.heightDefault);
                $0.top.equalTo(self);
                $0.bottom.equalTo(self);
            });
        }
    }
}
