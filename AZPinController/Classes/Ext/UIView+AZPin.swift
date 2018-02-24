//
//  UIView+AZPin.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
extension UIView {
    /// Method sets alpha to zero, animation optional
    ///
    /// - Parameter animated: if true, animates hiding
    /// - Parameter duration: animation duration
    func hide(animated: Bool = false, duration: TimeInterval = 0) {
        if !animated {
            self.alpha = 0;
            return;
        }
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                self?.alpha = 0;
        });
    }
    
    /// Undoes hide operation
    ///
    /// - Parameter animated: if true, animate revealing
    /// - Parameter duration: animation duration
    func unhide(animated: Bool = false, duration: TimeInterval = 0) {
        if !animated {
            self.alpha = 1;
            return;
        }
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                self?.alpha = 1;
        });
    }
    
    /// Transforms view into circle
    func circleUp() {
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = self.frame.width / 2;
    }
    
    /// Animates view horizontal trembling
    func trembleView(amplitude: CGFloat = 25, completion: @escaping () -> Void = {  }) {
        self.trembleHelper(
            shakeAmp: amplitude, ampUnit: amplitude / 5,
            completion: completion);
    }
    
}

extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

// MARK: - Private helpers
extension UIView {
    /// Recursive method called to perform a single animated oscillation
    ///
    /// - Parameter completion: completion closure
    fileprivate func trembleHelper(shakeAmp: CGFloat, ampUnit: CGFloat, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.05,
            animations: {
                self.transform = CGAffineTransform.init(translationX: shakeAmp, y: 0);
        },
            completion: { _ in
                if shakeAmp != 0 {
                    let nextShakeAmp = (abs(shakeAmp) - ampUnit) * -shakeAmp / abs(shakeAmp);
                    self.trembleHelper(shakeAmp: nextShakeAmp, ampUnit: ampUnit, completion: completion);
                } else {
                    self.transform = .identity;
                    completion();
                }
                
        });
    }
}
