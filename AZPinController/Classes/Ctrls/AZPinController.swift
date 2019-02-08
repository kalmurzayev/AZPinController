//
//  AZPinController.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit
import SnapKit
@objc public protocol AZPinControllerDelegate: class {
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
    open var pinLength: Int = 4 {
        didSet {
            _pinText = AZPinText(capacity: self.pinLength);
        }
    };
    open var pinValue: String {
        return _pinText.value;
    }
    open var pinEntryShakeOnError: Bool = true;
    open var pinEntryShineOnSuccess: Bool = true;
    open var pinEntryFillAnimate: Bool = true;
    open var closeOnSuccess: Bool = true;
    open var numPadAnimateTap: Bool = true {
        didSet {
            self.numPadView.numPadAnimateTap = self.numPadAnimateTap;
        }
    }
    // MARK: - subviews
    open var titleLabel: AZCommonLabel = {
        let label = AZCommonLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    /// If true, shows loading animation while processing deferred validator
    open var shouldAnimateLoading: Bool = false;
    open var statusLabel: AZCommonLabel = {
        let label = AZCommonLabel()
        label.numberOfLines = 2;
        label.textAlignment = .center;
        return label;
    }()
    open var pinField: AZPinField?;
    open var numPadView: AZNumPadView = AZNumPadView();
    open var closeButton: UIButton = UIButton(type: .system);
    open var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    open var deleteButton: UIButton = UIButton()
    fileprivate var _actIndicator: AZLoadingView?;
    open var pinValidator: AZPinValidating?
    open var stateMachine: AZPinControllerStateMachineProtocol?;
    weak open var delegate: AZPinControllerDelegate?;
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
    
    public convenience init(dataSet: AZPinDataSet) {
        self.init();
        _dataSet = dataSet;
    }

    override open func viewDidLoad() {
        super.viewDidLoad();
        self.setupText()
            .setupTitleLabel()
            .setupStatusLabel()
            .setupPinField()
            .setupNumPad()
            .setupLoadingView()
            .setupCloseButton()
            .setupRightButton()
            .setupDeleteButton()
            .finalizeView();
    }
    
    /// Target function to close the PinViewController
    @objc private func closeTapped() {
        self.dismiss(animated: true, completion: {
            self.delegate?.dismissedWithNoPinIn?(self);
        });
    }
}

// MARK: - View builders
extension AZPinController {
    fileprivate func setupText() -> Self {
        _pinText = AZPinText(capacity: self.pinLength);
        return self;
    }
    
    /// Setting up Top Title Label with layout constraints
    fileprivate func setupTitleLabel() -> Self {
        self.titleLabel.font = _dataSet.palette.fontTitle;
        self.titleLabel.textColor = _dataSet.palette.textColor;
        self.titleText = _dataSet.vocab.titleText;
        self.view.addSubview(self.titleLabel);
        setupTitleLabelConstraints()
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    /// Setting up Status Label with layout constraints
    fileprivate func setupStatusLabel() -> Self {
        self.view.addSubview(self.statusLabel);
        self.statusLabel.font = _dataSet.palette.fontDescription;
        self.statusLabel.textColor = _dataSet.palette.textColor;
        self.statusText = _dataSet.vocab.statusLabelInitText;
        setupStatusLabelConstraints()
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupStatusLabelConstraints() {
        self.statusLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
                .offset(_dataSet.blueprint.labelVerticalMargin);
            $0.leading.equalTo(self.view).offset(AZMargins.M);
            $0.trailing.equalTo(self.view).offset(-AZMargins.M);
        }
    }
    
    /// Setting up Pin Field with circle entries and layout constraints
    fileprivate func setupPinField() -> Self {
        let field = AZPinField(pinLength: self.pinLength);
        field.fillColor = _dataSet.palette.pinEntryFillColor;
        field.fillAnimate = self.pinEntryFillAnimate;
        field.successColor = _dataSet.palette.pinEntrySuccessColor;
        field.errorColor = _dataSet.palette.errorColor;
        self.view.addSubview(field);
        self.pinField = field;
        setupPinFieldConstraints()
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupPinFieldConstraints() {
        self.pinField?.snp.makeConstraints {
            $0.top.equalTo(self.statusLabel.snp.bottom)
                .offset(_dataSet.blueprint.pinFieldTopMargin);
            $0.centerX.equalTo(self.view);
        }
    }
    
    /// Setting up NumPad with layout constraints
    fileprivate func setupNumPad() -> Self {
        self.view.addSubview(self.numPadView);
        let width = _dataSet.blueprint.numPadButtonDiameter;
        setupNumPadConstraints()
        self.numPadView.buttonWidth = width;
        self.numPadView.delegate = self;
        self.numPadView.font = _dataSet.palette.fontDigits;
        self.numPadView.mainColor = _dataSet.palette.mainColor;
        self.numPadView.buttonBackgroundColor = _dataSet.palette.buttonBackgroundColor;
        self.numPadView.buttonBorder = (color: _dataSet.palette.buttonBorderColor, width: _dataSet.blueprint.buttonBorderWidth)
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupNumPadConstraints() {
        self.numPadView.snp.makeConstraints {
            $0.top.equalTo(pinField!.snp.bottom).offset(50.0);
            $0.centerX.equalTo(self.view);
            $0.width.equalTo(_dataSet.blueprint.numPadButtonDiameter * 3.0 + _dataSet.blueprint.numPadXPadding * 2.0);
            $0.height.equalTo(_dataSet.blueprint.numPadButtonDiameter * 4.0 + _dataSet.blueprint.numPadYPadding * 3.0);
        }
    }
    
    fileprivate func setupLoadingView() -> Self {
        if !self.shouldAnimateLoading { return self }
        let indicator = AZLoadingView();
        self.view.addSubview(indicator);
        _actIndicator = indicator;
        _actIndicator?.color = _dataSet.palette.mainColor
        guard let field = self.pinField else { return self }
        indicator.snp.makeConstraints { $0.center.equalTo(field) }
        return self;
    }
    
    /// Initiating Close button and adjusting layout constraints
    fileprivate func setupCloseButton() -> Self {
        self.closeButton.backgroundColor = UIColor.clear;
        self.closeButton.setTitleColor(_dataSet.palette.textColor, for: .normal);
        self.closeButton.titleLabel?.font = _dataSet.palette.fontDefault;
        self.closeButton.setTitle(_dataSet.vocab.closeText, for: .normal)
        self.closeButton.addTarget(
            self, action: #selector(closeTapped), for: .touchUpInside);
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.closeButton);
        setupCloseButtonConstraints()
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupCloseButtonConstraints() {
        self.closeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view)
                .offset(-_dataSet.blueprint.bottomOffset);
        }
        if let numPadLeftView = numPadView.leftMostView {
            self.closeButton.snp.makeConstraints {
                $0.centerX.equalTo(numPadLeftView)
            }
        } else {
            self.closeButton.snp.makeConstraints {
                $0.left.equalTo(numPadView.snp.left)
            }
        }
    }
    
    fileprivate func setupRightButton() -> Self {
        view.addSubview(rightButton)
        rightButton.backgroundColor = .clear
        rightButton.setImage(_dataSet.blueprint.rightMostButtonImage, for: .normal)
        rightButton.isHidden = false
        setupRightButtonConstraints()
        return self;
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupRightButtonConstraints() {
        rightButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
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
    }
    
    private func setupDeleteButton() -> Self {
        deleteButton.backgroundColor = UIColor.clear;
        deleteButton.setImage(_dataSet.blueprint.deleteImage, for: .normal);
        deleteButton.addTarget(
            self, action: #selector(deleteTapped), for: .touchUpInside);
        self.view.addSubview(deleteButton);
        deleteButton.isHidden = true
        setupDeleteButtonConstraints()
        return self
    }
    
    /// Override this function in order to customize constraints
    @objc open func setupDeleteButtonConstraints() {
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
        }
        if let numPadRightView = numPadView.rightMostView {
            deleteButton.snp.makeConstraints {
                $0.centerX.equalTo(numPadRightView)
            }
        } else {
            deleteButton.snp.makeConstraints {
                $0.right.equalTo(numPadView.snp.right)
            }
        }
    }
    
    fileprivate func finalizeView() {
        view.backgroundColor = _dataSet.palette.backgroundColor;
    }
    
    /// Helper invoked when delete button is tapped
    @objc private func deleteTapped() {
        _pinText.delete()
        self.pinField?.deleteEntry();
        if _pinText.length == 0 {
            deleteButton.isHidden = true
            rightButton.isHidden = false
        }
    }
    
    /// resets pin data and pin field
    open func reset() {
        self.pinField?.reset();
        _pinText.reset();
        deleteButton.isHidden = true
        rightButton.isHidden = false
    }
    
    /// When needed, hides the field and starts loading
    open func startLoading() {
        if !self.shouldAnimateLoading { return }
        self.pinField?.hide();
        _actIndicator?.startAnimating();
        
    }
    
    /// Stops loading animation
    open func stopLoading() {
        self.pinField?.unhide();
        _actIndicator?.endAnimating();
    }
}

// MARK: - SBNumPadDelegate methods
extension AZPinController: AZNumPadDelegate {
    func numPad(_ numPad: AZNumPadView, enteredValue: String) {
        _pinText.add(enteredValue);
        self.pinField?.addEntry();
        self.delegate?.pinViewController?(self, updatedPin: _pinText.value);
        if _pinText.length > 0 {
            deleteButton.isHidden = false
            rightButton.isHidden = true
        }
        if _pinText.length == self.pinLength {
            self.handleFullPin();
        }
    }
    
    /// Handles all cases when entire PIN is entered
    private func handleFullPin() {
        if self.delegate == nil && self.pinValidator == nil { return }
        if let machine = stateMachine {
            machine.shift(with: self)
            return
        }
        handlePinValResult(_pinText.value)
    }
    
    /// Execution logic for pin entering first round
    open func doFirstRoundCompletion() {
        _pinCodeTemp = _pinText.value;
        self.reset();
        _titleTemp = self.titleText;
        self.titleText = _dataSet.vocab.repeatPinText;
        return;
    }
    
    /// Execution logic for pin entering last round
    open func doFinalRoundCompletion() {
        self.handlePinValResult(_pinText.value);
    }
    
    /// Execution logic for showing error when pins do not match
    open func doMismatchErrorCompletion() {
        self.reset();
        self.titleText = _titleTemp;
        self.pinField?.trembleError();
        self.statusColor = _dataSet.palette.errorColor;
        self.statusText = _dataSet.vocab.pinsNotMatchText;
    }
    
    
    /// Used as a deffered callback during deffered pin validation
    private func handlePinValResult(_ value: String) {
        guard let val = self.pinValidator else { return }
        let isValid = val.validate(value)
        if isValid {
            if self.pinEntryShineOnSuccess {
                self.pinField?.fillSuccess();
            }
            if self.closeOnSuccess {
                self.perform(#selector(closeWithSuccess), with: nil, afterDelay: 1.0);
                return;
            }
            self.delegate?.pinSuccessIn?(self);
            return
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
