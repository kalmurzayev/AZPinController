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
    static let animationDurationDefault: Double = 0.3;
    weak var delegate: AZNumPadButtonDelegate?;
    var mainColor: UIColor = .black {
        didSet {
            _digitLabel.textColor = mainColor
            _lettersLabel.textColor = mainColor
        }
    }
    var subLetterColor: UIColor = .gray {
        didSet {
            _lettersLabel.textColor = subLetterColor
        }
    }
    var tapAnimate: Bool = true {
        didSet {
            _animationDuration = self.tapAnimate
                ? AZPinFieldEntry.animationDurationDefault : 0;
        }
    }
    var font: UIFont = UIFont.systemFont(ofSize: 32) {
        didSet {
            _digitLabel.font = self.font;
        }
    }
    var buttonText: String? {
        didSet {
            if buttonText == nil { return }
            _digitLabel.text = buttonText;
        }
    }
    var lettersText: String? {
        didSet {
            _lettersLabel.text = lettersText
        }
    }
    var valueText: String?;
    private var _animationDuration: TimeInterval = AZPinFieldEntry.animationDurationDefault;
    private var _digitLabel = AZCommonLabel();
    private var _lettersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10.0, weight: .medium)
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
        self.layer.masksToBounds = true;
        self.setupDigitLabel();
        self.setupLettersLabel();
        self.setupTap();
    }
    
    /// Initiates Digit label, adds to view
    private func setupDigitLabel() {
        _digitLabel.textAlignment = .center;
        _digitLabel.font = self.font;
        _digitLabel.backgroundColor = UIColor.clear;
        self.addSubview(_digitLabel);
        _digitLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // TODO: use blueprint
            _digitLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor, constant: -8),
            _digitLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    private func setupLettersLabel() {
        addSubview(_lettersLabel)
        NSLayoutConstraint.activate([
            _lettersLabel.topAnchor.constraint(equalTo: _digitLabel.bottomAnchor),
            _lettersLabel.centerXAnchor.constraint(equalTo: _digitLabel.centerXAnchor)
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
                self.backgroundColor!.cgColor,
                self.mainColor.cgColor];
            colorKeyframeAnimation.keyTimes = [
                0, NSNumber(value: AZNumPadButton.animationDurationDefault / 2.0)];
            colorKeyframeAnimation.duration = AZNumPadButton.animationDurationDefault;
            self.layer.add(colorKeyframeAnimation, forKey: nil);
        }
        self.delegate?.numPadButtonTapped(self);
    }
}
