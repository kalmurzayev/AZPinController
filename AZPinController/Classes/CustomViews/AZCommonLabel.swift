//
//  AZCommonLabel.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
public class AZCommonLabel: UILabel {
    static let heightDefault: CGFloat = 20;
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.initiateViews();
    }
    
    convenience public init() {
        self.init(frame: CGRect.zero);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    private func initiateViews() {
        self.numberOfLines = 0;
        self.textAlignment = .left;
    }
}
