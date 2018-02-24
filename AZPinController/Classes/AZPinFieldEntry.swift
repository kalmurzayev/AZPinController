//
//  AZPinFieldEntry.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import Foundation
import UIKit;

class AZPinFieldEntry: UIView {
    static let animationDurationDefault: TimeInterval = 0.2;
    var fillColor: UIColor = UIColor.black {
        didSet {
            self.adjustColors();
        }
    };
    var successColor: UIColor = UIColor.green;
    var errorColor: UIColor = UIColor.red;
    var fillAnimate: Bool = true {
        didSet {
            _animationDuration = self.fillAnimate ? AZPinFieldEntry.animationDurationDefault : 0;
        }
    };
    private var _animationDuration: TimeInterval = AZPinFieldEntry.animationDurationDefault;
    // MARK: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initiateViews();
    }
    
    convenience init() {
        self.init(frame: CGRect.zero);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /// MARK: - Color actions
    
    /// Fills FieldEntry with fill color
    func fill() {
        UIView.animate(withDuration: _animationDuration, animations: {
            self.backgroundColor = self.fillColor;
        });
    }
    
    /// Cleans Entry and sets color back to white
    func reset() {
        UIView.animate(withDuration: _animationDuration, animations: {
            self.adjustColors();
        });
    }
    
    /// Fills Entry with success color
    func fillSuccess() {
        self.layer.borderColor = self.successColor.cgColor;
        self.backgroundColor = self.successColor;
    }
    
    /// Fills border with error color
    func fillError() {
        self.backgroundColor = UIColor.white;
        self.layer.borderColor = self.errorColor.cgColor;
    }
    
    /// Initiates itself and sets layout constraints
    private func initiateViews() {
        self.snp.makeConstraints({
            $0.height.equalTo(self.snp.width);
        });
        self.layer.borderWidth = 1;
        self.layer.masksToBounds = true;
        self.adjustColors();
    }
    
    /// Sets FieldEntry colors, used by computed property fillColor
    private func adjustColors() {
        self.backgroundColor = .clear;
        self.layer.borderColor = self.fillColor.cgColor;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.circleUp();
    }
}
