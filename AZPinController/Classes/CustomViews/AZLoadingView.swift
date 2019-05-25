//
//  AZLoadingView.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
class AZLoadingView: UIView {
    static let sizeDefault = CGSize(width: 24, height: 24);
    static let colorDefault = UIColor(hex: 0x9595ac);
    private var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.color = AZLoadingView.colorDefault;
        view.hidesWhenStopped = true;
        return view;
    }()
    var color: UIColor = AZLoadingView.colorDefault {
        didSet {
            indicator.color = color
        }
    }
    // MARK: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    convenience init() {
        self.init(frame: CGRect.zero);
        self.initiateView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /// Sets up and lays out icon and its gradient background
    fileprivate func initiateView() {
        self.backgroundColor = .white;
        self.addSubview(self.indicator);
        self.indicator.snp.makeConstraints {
            $0.size.equalTo(AZLoadingView.sizeDefault);
            $0.center.equalTo(self);
        }
    }
    
    func startAnimating() {
        self.indicator.startAnimating();
    }
    
    func endAnimating() {
        self.indicator.stopAnimating();
    }
}
