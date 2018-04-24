//
//  AZPinStateMachine.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 4/24/18.
//

import Foundation
public protocol AZPinControllerStateMachineProtocol: class {
    func shift(with ctrl: AZPinController);
}

open class AZPinRepeatStateMachine: AZPinControllerStateMachineProtocol {
    enum CtrlState: Int {
        case firstRun;
        case repeatRun;
    }
    private var _pinCodeTemp: String?
    private var current: CtrlState = .firstRun;
    open func shift(with ctrl: AZPinController) {
        switch current {
        case .firstRun:
            _pinCodeTemp = ctrl.pinValue
            ctrl.doFirstRoundCompletion()
        case .repeatRun:
            if _pinCodeTemp == ctrl.pinValue {
                ctrl.doFinalRoundCompletion()
            } else {
                ctrl.doMismatchErrorCompletion()
            }
        }
        self.increment();
    }
    
    private func increment() {
        let next: Int = (current.rawValue + 1) % 2;
        current = CtrlState(rawValue: next)!;
    }
}
