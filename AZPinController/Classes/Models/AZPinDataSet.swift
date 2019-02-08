//
//  AZPinDataSet.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation

enum AZMargins {
    static let marginUnit: CGFloat = 4;
    static let M: CGFloat = 4 * marginUnit;
    static let L: CGFloat = 6 * marginUnit;
    static let XL: CGFloat = 8 * marginUnit;
}

/// Struct containing all geometry related values
public struct AZPinBlueprint {
    public var numPadXPadding: CGFloat = AZMargins.L;
    public var numPadYPadding: CGFloat = AZMargins.M;
    public var bottomOffset: CGFloat = AZMargins.XL;
    public var numPadButtonDiameter: CGFloat = 72;
    public var deleteImage: UIImage?
    public var rightMostButtonImage: UIImage?
    public var labelVerticalMargin: CGFloat = AZMargins.marginUnit;
    public var pinFieldTopMargin: CGFloat = AZMargins.L;
    public var buttonBorderWidth: CGFloat = 0.0
}

/// Struct containing all text related values
public struct AZPinVocabulary {
    public var titleText = "Pin Code";
    public var statusLabelInitText = "Please enter your PIN";
    public var repeatPinText = "Please repeat your PIN";
    public var pinsNotMatchText = "Pin codes should match";
    public var cancelText = "Cancel";
    public var closeText = "Close";
}

/// Struct containing colors and fonts
public struct AZPinPalette {
    public var fontDefault: UIFont = UIFont.systemFont(ofSize: 15);
    public var fontTitle: UIFont = UIFont.systemFont(ofSize: 19.0);
    public var fontDigits: UIFont = UIFont.systemFont(ofSize: 32)
    public var fontDescription: UIFont = UIFont.systemFont(ofSize: 13);
    public var errorColor: UIColor = UIColor(hex: 0xe5466e);
    public var successColor: UIColor = UIColor(hex: 0x1ed7c5);
    public var mainColor: UIColor = UIColor(hex: 0x666666);
    public var buttonBorderColor = UIColor.clear
    public var textColor = UIColor(hex: 0x666666);
    public var backgroundColor: UIColor = UIColor.white;
    public var pinEntryFillColor: UIColor = UIColor(hex: 0x26a9e0)
    public var pinEntrySuccessColor: UIColor = UIColor(hex: 0x1ed7c5);
    public var buttonBackgroundColor: UIColor = UIColor(hex: 0xFFFFFF, alpha: 0.4);
    
}

/// Data set with values for PinController visual properties
/// All dataset properties have default values
public struct AZPinDataSet {
    public var blueprint = AZPinBlueprint();
    public var vocab = AZPinVocabulary();
    public var palette = AZPinPalette();
    public init() { }
}
