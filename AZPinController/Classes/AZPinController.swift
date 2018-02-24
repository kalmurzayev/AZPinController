//
//  AZPinController.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit
import SnapKit
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
    };
    // MARK: - subviews
    open var titleLabel: AZCommonLabel = {
        let label = AZCommonLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    /// Set to true if pPIN code needs to be repeated before validation
    open var shouldConfirmPin: Bool = false;
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
    fileprivate var _actIndicator: AZLoadingView?;
    open var pinValidator: AZPinValidating?
    weak var delegate: AZPinControllerDelegate?;
    // MARK: - Private properties
    fileprivate var _pinText: AZPinText!;
    fileprivate var _isRepeatingPin: Bool = false;
    fileprivate var _titleTemp: String?;
    fileprivate var _pinCodeTemp: String?;
    fileprivate var _stateMachine: AZPinControllerStateMachineProtocol?;
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
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        return self;
    }
    
    /// Setting up Status Label with layout constraints
    fileprivate func setupStatusLabel() -> Self {
        self.view.addSubview(self.statusLabel);
        self.statusLabel.font = _dataSet.palette.fontDescription;
        self.statusLabel.textColor = _dataSet.palette.textColor;
        self.statusLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
                .offset(_dataSet.blueprint.labelVerticalMargin);
            $0.centerX.equalTo(self.view);
        }
        self.statusText = _dataSet.vocab.statusLabelInitText;
        return self;
    }
    
    /// Setting up Pin Field with circle entries and layout constraints
    fileprivate func setupPinField() -> Self {
        let field = AZPinField(pinLength: self.pinLength);
        field.fillColor = _dataSet.palette.pinEntryFillColor;
        field.fillAnimate = self.pinEntryFillAnimate;
        field.successColor = _dataSet.palette.pinEntrySuccessColor;
        field.errorColor = _dataSet.palette.errorColor;
        self.view.addSubview(field);
        field.snp.makeConstraints {
            $0.top.equalTo(self.statusLabel.snp.bottom)
                .offset(_dataSet.blueprint.pinFieldTopMargin);
            $0.centerX.equalTo(self.view);
        }
        self.pinField = field;
        return self;
    }
    
    /// Setting up NumPad with layout constraints
    fileprivate func setupNumPad() -> Self {
        self.view.addSubview(self.numPadView);
        self.numPadView.deleteButtonImage = _dataSet.blueprint.deleteImage;
        let width = _dataSet.blueprint.numPadButtonDiameter;
        self.numPadView.snp.makeConstraints {
            $0.top.equalTo(pinField!.snp.bottom).offset(50.0);
            $0.centerX.equalTo(self.view);
            $0.width.equalTo(width * 3.0 + _dataSet.blueprint.numPadXPadding * 2.0);
            $0.height.equalTo(width * 4.0 + _dataSet.blueprint.numPadYPadding * 3.0);
        }
        self.numPadView.buttonWidth = width;
        self.numPadView.delegate = self;
        self.numPadView.font = _dataSet.palette.fontDigits;
        self.numPadView.mainColor = _dataSet.palette.mainColor;
        self.numPadView.buttonBackgroundColor = _dataSet.palette.buttonBackgroundColor;
        return self;
    }
    
    fileprivate func setupLoadingView() -> Self {
        if !self.shouldAnimateLoading { return self }
        let indicator = AZLoadingView();
        self.view.addSubview(indicator);
        _actIndicator = indicator;
        
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
        self.closeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view)
                .offset(-_dataSet.blueprint.bottomOffset);
        }
        if let numPadLeftView = numPadView.leftMostView {
            self.closeButton.snp.makeConstraints {
                $0.centerX.equalTo(numPadLeftView)
            }
            return self;
        }
        self.closeButton.snp.makeConstraints {
            $0.left.equalTo(numPadView.snp.left)
        }
        return self;
    }
    
    fileprivate func setupRightButton() -> Self {
        if !shouldConfirmPin { return self }
        view.addSubview(rightButton)
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
        rightButton.addTarget(
            self, action: #selector(closeTapped), for: .touchUpInside)
        return self;
    }
    
    fileprivate func finalizeView() {
        view.backgroundColor = _dataSet.palette.backgroundColor;
        if shouldConfirmPin {
            _stateMachine = AZPinStateMachine();
        }
    }
}

// MARK: - Publics
extension AZPinController {
    /// resets pin data and pin field
    func reset() {
        self.pinField?.reset();
        _pinText.reset();
    }
}

fileprivate protocol AZPinControllerStateMachineProtocol: class {
    func shift(with ctrl: AZPinController);
    
}

fileprivate class AZPinStateMachine: AZPinControllerStateMachineProtocol {
    enum CtrlState: Int {
        case firstRun;
        case repeatRun;
    }
    
    private var current: CtrlState = .firstRun;
    func shift(with ctrl: AZPinController) {
        switch current {
        case .firstRun:
            ctrl.doFirstRoundCompletion();
            break;
        default:
            ctrl.doLastRoundCompletion();
            break;
        }
        self.increment();
    }
    
    private func increment() {
        let next: Int = (current.rawValue + 1) % 2;
        current = CtrlState(rawValue: next)!;
    }
}

// MARK: - SBNumPadDelegate methods
extension AZPinController: AZNumPadDelegate {
    func numPad(_ numPad: AZNumPadView, enteredValue: String) {
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
            _stateMachine?.shift(with: self);
            return;
        }
        self.handlePinValResult(_pinText.value);
    }
    
    /// Execution logic for pin entering first round
    fileprivate func doFirstRoundCompletion() {
        _pinCodeTemp = _pinText.value;
        self.reset();
        _titleTemp = self.titleText;
        self.titleText = _dataSet.vocab.repeatPinText;
        self.statusText = nil;
        self.statusColor = _dataSet.palette.errorColor;
        return;
    }
    
    /// Execution logic for pin entering last round
    fileprivate func doLastRoundCompletion() {
        if _pinText.value == _pinCodeTemp {
            self.handlePinValResult(_pinText.value);
            return;
        }
        self.reset();
        self.titleText = _titleTemp;
        self.pinField?.trembleError();
        self.statusText = _dataSet.vocab.pinsNotMatchText;
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
    fileprivate func handlePinValResult(_ value: String) {
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
