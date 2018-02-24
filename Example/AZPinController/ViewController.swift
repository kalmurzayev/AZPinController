//
//  ViewController.swift
//  AZPinController
//
//  Created by kalmurzayev on 02/24/2018.

import UIKit
import SnapKit
import AZPinController
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad();
        self.initiateViews();
    }
    
    private func initiateViews() {
        let button = UIButton();
        button.setTitle("Tap to present PIN", for: .normal);
        button.setTitleColor(.blue, for: .normal);
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside);
        self.view.addSubview(button);
        button.snp.makeConstraints {
            $0.center.equalTo(self.view);
        }
    }
    
    @objc private func tapped() {
        var set = AZPinDataSet()
        set.blueprint.deleteImage = UIImage(named: "step-backward");
        let ctrl = AZPinController(dataSet: set);
        ctrl.shouldConfirmPin = true;
        ctrl.pinLength = 6;
        ctrl.pinValidator = AZPinValidator(pinLength: 6);
        self.present(ctrl, animated: true);
    }
}

