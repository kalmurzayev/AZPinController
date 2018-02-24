//
//  AZNumPadButton.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit;

protocol AZNumPadButtonDelegate: class {
    /// Called on delegate when button is tapped
    ///
    /// - Parameter button: Caller NumPadButton instance
    func numPadButtonTapped(_ button: AZNumPadButton);
}

class AZNumPadButton: UIView {
    static let animationDurationDefault: Double = 0.2;
    weak var delegate: AZNumPadButtonDelegate?;
    var mainColor: UIColor = .black {
        didSet {
            self.adjustColors();
        }
    }
    var tapAnimate: Bool = true {
        didSet {
            self._animationDuration = self.tapAnimate ? AZPinFieldEntry.animationDurationDefault : 0;
        }
    };
    var font: UIFont = UIFont.systemFont(ofSize: 36) {
        didSet {
            self._digitLabel.font = self.font;
        }
    };
    var buttonText: String? {
        didSet {
            if self.buttonText == nil { return }
            self._digitLabel.text = self.buttonText;
        }
    }
    var lettersText: String? {
        didSet {
            lettersLabel.text = lettersText
        }
    }
    var valueText: String?;
    private var _animationDuration: TimeInterval = AZPinFieldEntry.animationDurationDefault;
    private var _digitLabel = AZCommonLabel();
    private var lettersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        label.textColor = .white
        return label
    }()
    // MARK: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    convenience init() {
        self.init(frame: CGRect.zero);
        self.initiateViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.circleUp();
    }
    
    /// Initiates itself and sets layout constraints
    private func initiateViews() {
        self.snp.makeConstraints({
            $0.height.equalTo(self.snp.width);
        });
        self.setupDigitLabel();
        self.setupLettersLabel();
        self.adjustColors();
        self.setupTap();
    }
    
    /// Initiates Digit label, adds to view
    private func setupDigitLabel() {
        self._digitLabel.textAlignment = .center;
        self._digitLabel.font = self.font;
        self._digitLabel.backgroundColor = UIColor.clear;
        self.addSubview(self._digitLabel);
        self._digitLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // use blueprint
            _digitLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor, constant: -8),
            _digitLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    private func setupLettersLabel() {
        addSubview(lettersLabel)
        NSLayoutConstraint.activate([
            lettersLabel.topAnchor.constraint(equalTo: _digitLabel.bottomAnchor),
            lettersLabel.centerXAnchor.constraint(equalTo: _digitLabel.centerXAnchor)
            ])
    }
    
    /// Setting up tap event, adding optional animation and calling delegate method
    private func setupTap() {
        let gesture = UITapGestureRecognizer(
            target: self, action: #selector(handleTapGesture(recognizer:)));
        self.isUserInteractionEnabled = true;
        self.addGestureRecognizer(gesture);
    }
    
    /// Handles tap gesture to animate button and call delegate method
    ///
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc private func handleTapGesture(recognizer: UITapGestureRecognizer) {
        if self.tapAnimate {
            let colorKeyframeAnimation = CAKeyframeAnimation(keyPath: "backgroundColor");
            // TODO: use palette
            colorKeyframeAnimation.values = [
                UIColor(hex: 0xFFFFFF, alpha: 0.4).cgColor,
                UIColor.white.cgColor];
            colorKeyframeAnimation.keyTimes = [
                0, NSNumber(value: AZNumPadButton.animationDurationDefault / 2.0)];
            colorKeyframeAnimation.duration = AZNumPadButton.animationDurationDefault;
            self.layer.add(colorKeyframeAnimation, forKey: nil);
        }
        self.delegate?.numPadButtonTapped(self);
    }
    
    /// Sets All colors, used by computed property fillColor
    private func adjustColors() {
        // TODO: get from palette
        self.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 0.4);
        _digitLabel.textColor = UIColor.white;
    }
}
