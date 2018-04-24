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
        set.vocab.titleText = "Введите текущий код доступа"
        set.palette.buttonBackgroundColor = UIColor(hex: 0xffffff, alpha: 0.4)
        set.palette.textColor = .white
        set.palette.mainColor = .white
        set.palette.pinEntryFillColor = .white
        set.blueprint.deleteImage = #imageLiteral(resourceName: "step-backward")
        set.blueprint.rightMostButtonImage = #imageLiteral(resourceName: "icAlertTouchid")
        let ctrl = AZPinController(dataSet: set);
        ctrl.pinLength = 6;
        ctrl.pinValidator = AZPinValidator(pinLength: 6);
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.locations = [0, 0.6, 1]
        gradientLayer.colors = [UIColor(hex: 0x7ad8ff).cgColor, UIColor(hex: 0x1ca2db).cgColor]
        let backView = UIView()
        backView.frame = UIScreen.main.bounds
        backView.layer.addSublayer(gradientLayer)
        ctrl.view.insertSubview(backView, at: 0)
        self.present(ctrl, animated: true);
    }
}

