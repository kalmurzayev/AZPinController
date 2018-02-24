//
//  AZPinController.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit;
import SnapKit;

@objc protocol AZPinControllerDelegate: class {
    /// Delegate method to notify n-th pin entry is activated. Not called, when validation method is called
    @objc optional func pinViewController(_ controller: AZPinController, updatedPin: String);
    /// Delegate method to notify n-th pin entry is activated. Not called, when validation method is called
    @objc optional func pinCodeFilledIn(_ controller: AZPinController);
    /// Delegate method to notify if correct pin is entered
    @objc optional func pinSuccessIn(_ controller: AZPinController);
    /// Delegate method to notify if wrong pin is entered
    @objc optional func pinFailureIn(_ controller: AZPinController);
    /// Delegate method to notify that controller is dismissed with no pin
    @objc optional func dismissedWithNoPinIn(_ controller: AZPinController);
}

open class AZPinController: UIViewController {
    // MARK: - static dimensions
    open var closeButtonSize: CGSize = CGSize(width: 100, height: 20) {
        didSet {
            self.closeButton.snp.updateConstraints {
                $0.size.equalTo(closeButtonSize);
            }
        }
    }
    // MARK: - parameters
    open var closeButtonTitle: String? {
        get {
            return self.closeButton.titleLabel?.text;
        }
        set {
            self.closeButton.setTitle(newValue, for: .normal);
        }
    }
    open var statusText: String? {
        get {
            return self.statusLabel.text;
        }
        set {
            self.statusLabel.text = newValue;
        }
    }
    open var statusFont: UIFont? {
        get {
            return self.statusLabel.font;
        }
        set {
            self.statusLabel.font = newValue;
        }
    }
    open var statusColor: UIColor? {
        get {
            return self.statusLabel.textColor;
        }
        set {
            self.statusLabel.textColor = newValue;
        }
    }
    open var titleText: String? {
        get {
            return self.titleLabel.text;
        }
        set {
            self.titleLabel.text = newValue;
        }
    }
    open var titleFont: UIFont? {
        get {
            return self.titleLabel.font;
        }
        set {
            self.titleLabel.font = newValue;
        }
    }
    open var titleColor: UIColor? {
        get {
            return self.titleLabel.textColor;
        }
        set {
            self.titleLabel.textColor = newValue;
        }
    }
    
    fileprivate var _dataSet = AZPinDataSet();
    // MARK: - PIN entry properties
    var pinEntryFillColor: UIColor?;
    var mainBackgroundColor: UIColor?
    var pinEntrySuccessColor: UIColor?;
    var pinEntryErrorColor: UIColor?;
    var pinLength: Int = 4 {
        didSet {
            _pinText = AZPinText(capacity: self.pinLength);
        }
    };
    var pinValue: String {
        return _pinText.value;
    }
    var pinEntryShakeOnError: Bool = true;
    var pinEntryShineOnSuccess: Bool = true;
    var pinEntryFillAnimate: Bool = true;
    var closeOnSuccess: Bool = true;
    // MARK: - Num Pad properties
    var numPadMainColor: UIColor? {
        didSet {
            self.numPadView.mainColor = self.numPadMainColor;
        }
    };
    var numPadFont: UIFont? {
        didSet {
            self.numPadView.font = self.numPadFont;
        }
    };
    var numPadAnimateTap: Bool = true {
        didSet {
            self.numPadView.numPadAnimateTap = self.numPadAnimateTap;
        }
    };
    // MARK: - subviews
    var titleLabel: AZCommonLabel = {
        let label = AZCommonLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // label.font = BAGlobals.FONT_TITLE
        return label
    }()
    /// Set to true if pPIN code needs to be repeated before validation
    var shouldConfirmPin: Bool = false;
    /// If true, shows loading animation while processing deferred validator
    var shouldAnimateLoading: Bool = false;
    var statusLabel: AZCommonLabel = {
        let label = AZCommonLabel()
        label.numberOfLines = 2;
        label.textAlignment = .center;
        return label;
    }()
    var pinField: AZPinField?;
    var numPadView: AZNumPadView = AZNumPadView();
    var closeButton: UIButton = UIButton(type: .system);
    var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    fileprivate var _actIndicator: AZLoadingView?;
    var pinValidator: AZPinValidating?
    weak var delegate: AZPinControllerDelegate?;
    // MARK: - Private properties
    fileprivate var _pinText: AZPinText!;
    fileprivate var _isRepeatingPin: Bool = false;
    fileprivate var _titleTemp: String?;
    fileprivate var _pinCodeTemp: String?;
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    public required init() {
        super.init(nibName: nil, bundle: nil);
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad();
        self.initiateViews();
    }
    
    /// resets pin data and pin field
    func reset() {
        self.pinField?.reset();
        _pinText.reset();
    }
    
    // MARK: - Initiate subviews
    /// Initiating subviews and adjusting their layout constraints
    private func initiateViews() {
        // NOTE: please do not alter the order of following function calls, otherwise will break SnapKit constraint creation
        _pinText = AZPinText(capacity: self.pinLength);
        self.setupTitleLabel();
        self.setupStatusLabel();
        self.setupPinField();
        self.setupNumPad();
        self.setupLoadingView();
        self.setupCloseButton();
        self.setupRightButton();
        view.backgroundColor = mainBackgroundColor
    }
    
    /// Setting up NumPad with layout constraints
    private func setupNumPad() {
        self.view.addSubview(self.numPadView);
        let width = _dataSet.blueprint.numPadButtonDiameter;
        self.numPadView.snp.makeConstraints {
            $0.top.equalTo(pinField!.snp.bottom).offset(50.0);
            $0.centerX.equalTo(self.view);
            $0.width.equalTo(width * 3.0 + _dataSet.blueprint.numPadXPadding * 2.0);
            $0.height.equalTo(width * 4.0 + _dataSet.blueprint.numPadYPadding * 3.0);
        }
        self.numPadView.buttonWidth = width;
        self.numPadView.delegate = self;
    }
    
    /// Setting up Status Label with layout constraints
    private func setupStatusLabel() {
        self.view.addSubview(self.statusLabel);
        self.statusLabel.snp.makeConstraints({
            $0.top.equalTo(self.titleLabel.snp.bottom)
                .offset(_dataSet.blueprint.labelVerticalMargin);
            $0.centerX.equalTo(self.view);
        });
        if shouldConfirmPin {
            statusLabel.textColor = .white
            statusLabel.text = _dataSet.vocab.statusLabelInitText;
        }
    }
    
    /// Setting up Pin Field with circle entries and layout constraints
    private func setupPinField() {
        self.pinField = AZPinField(pinLength: self.pinLength);
        self.pinField?.fillColor = self.pinEntryFillColor;
        self.pinField?.fillAnimate = self.pinEntryFillAnimate;
        self.pinField?.successColor = self.pinEntrySuccessColor;
        self.pinField?.errorColor = self.pinEntryErrorColor;
        self.view.addSubview(self.pinField!);
        self.pinField!.snp.makeConstraints {
            $0.top.equalTo(self.statusLabel.snp.bottom)
                .offset(_dataSet.blueprint.pinFieldTopMargin);
            $0.centerX.equalTo(self.view);
        }
    }
    
    fileprivate func setupLoadingView() {
        if !self.shouldAnimateLoading { return }
        let indicator = AZLoadingView();
        self.view.addSubview(indicator);
        _actIndicator = indicator;
        
        guard let field = self.pinField else { return }
        indicator.snp.makeConstraints { $0.center.equalTo(field) }
    }
    
    /// Setting up Top Title Label with layout constraints
    private func setupTitleLabel() {
        self.view.addSubview(self.titleLabel);
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    /// Initiating Close button and adjusting layout constraints
    private func setupCloseButton() {
        self.closeButton.backgroundColor = UIColor.clear;
        self.closeButton.setTitleColor(UIColor.white, for: .normal);
        self.closeButton.titleLabel?.font = _dataSet.palette.fontDefault;
        self.closeButton.addTarget(
            self, action: #selector(closeTapped), for: .touchUpInside);
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.closeButton);
        self.closeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view).offset(-_dataSet.blueprint.bottomOffset);
        }
        if let numPadLeftView = numPadView.leftMostView {
            self.closeButton.snp.makeConstraints {
                $0.centerX.equalTo(numPadLeftView)
            }
            return;
        }
        self.closeButton.snp.makeConstraints {
            $0.left.equalTo(numPadView.snp.left)
        }
    }
    
    private func setupRightButton() {
        view.addSubview(rightButton)
        if shouldConfirmPin {
            rightButton.setTitle(_dataSet.vocab.skipButtonText, for: .normal)
            rightButton.snp.makeConstraints {
                $0.bottom.equalTo(self.view)
                    .offset(-_dataSet.blueprint.bottomOffset);
            }
            if let numPadRightView = numPadView.rightMostView {
                rightButton.snp.makeConstraints {
                    $0.centerX.equalTo(numPadRightView)
                }
            } else {
                rightButton.snp.makeConstraints {
                    $0.right.equalTo(numPadView.snp.right)
                }
            }
            rightButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            closeButton.isHidden = true
            return
        }
    }
    
    /// Target function to close the PinViewController
    @objc private func closeTapped() {
        self.dismiss(animated: true, completion: {
            self.delegate?.dismissedWithNoPinIn?(self);
        });
    }
}

// MARK: - SBNumPadDelegate methods
extension AZPinController: AZNumPadDelegate {
    func numPad(_ numPad: AZNumPadView, enteredValue: String) {
        if !shouldConfirmPin || _isRepeatingPin {
            self.statusText = nil;
        }
        _pinText.add(enteredValue);
        self.pinField?.addEntry();
        self.delegate?.pinViewController?(self, updatedPin: _pinText.value);
        if _pinText.length == self.pinLength {
            self.handleFullPin();
        }
    }
    func deleteTappedIn(numPad: AZNumPadView) {
        _pinText.delete();
        self.pinField?.deleteEntry();
    }
    
    /// Handles all cases when entire PIN is entered
    private func handleFullPin() {
        if self.delegate == nil && self.pinValidator == nil { return }
        
        // if pin needs to be repeated
        if self.shouldConfirmPin {
            _isRepeatingPin = !_isRepeatingPin;
            // if entering the first time
            if _isRepeatingPin {
                _pinCodeTemp = _pinText.value;
                self.reset();
                _titleTemp = self.titleText;
                self.titleText = _dataSet.vocab.repeatPinText;
                self.statusText = nil;
                self.statusColor = _dataSet.palette.errorColor;
                return;
            }
            // if entering the second time
            if _pinText.value != _pinCodeTemp {
                self.reset();
                self.titleText = _titleTemp;
                self.pinField?.trembleError();
                self.statusText = _dataSet.vocab.pinsNotMatchText;
                return;
            }
        }
        guard let val = self.pinValidator else { return }
        self.startLoading();
        let isValid = val.validate(_pinText.value)
        self.handlePinValResult(isValid: isValid)
    }
    
    /// When needed, hides the field and starts loading
    fileprivate func startLoading() {
        if !self.shouldAnimateLoading { return }
        self.pinField?.hide();
        _actIndicator?.startAnimating();
        
    }
    
    /// Stops loading animation
    fileprivate func stopLoading() {
        self.pinField?.unhide();
        _actIndicator?.endAnimating();
    }
    
    /// Used as a deffered callback during deffered pin validation
    ///
    /// - Parameter isValid: validation result
    fileprivate func handlePinValResult(isValid: Bool) {
        self.stopLoading();
        if isValid {
            if self.pinEntryShineOnSuccess {
                self.pinField?.fillSuccess();
            }
            if self.closeOnSuccess {
                self.perform(#selector(closeWithSuccess), with: nil, afterDelay: 1.0);
            } else {
                self.delegate?.pinSuccessIn?(self);
            }
            return;
        }
        
        self.reset();
        self.delegate?.pinFailureIn?(self);
        if self.pinEntryShakeOnError {
            self.pinField?.trembleError();
        }
    }
    
    @objc private func closeWithSuccess() {
        self.dismiss(animated: true) { [weak self] in
            self!.delegate?.pinSuccessIn?(self!);
        }
    }
    
    /// Closes presented controller
    @objc private func close() {
        self.dismiss(animated: true, completion: nil);
    }
}
