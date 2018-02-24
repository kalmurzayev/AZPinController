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

struct AZPinBlueprint {
    var numPadXPadding: CGFloat = AZMargins.L;
    var numPadYPadding: CGFloat = AZMargins.M;
    var bottomOffset: CGFloat = AZMargins.XL;
    var numPadButtonDiameter: CGFloat = 36;
    var deleteImage: UIImage!;
    var labelVerticalMargin: CGFloat = AZMargins.marginUnit;
    var pinFieldTopMargin: CGFloat = AZMargins.L;
}

struct AZPinVocabulary {
    var skipButtonText = "Skip";
    var statusLabelInitText = "Please enter your PIN";
    var repeatPinText = "Please repeat your PIN";
    var pinsNotMatchText = "Pin codes should match";
    var cancelText = "Cancel";
}

struct AZPinPalette {
    var fontDefault = UIFont.systemFont(ofSize: 15);
    var fontTitle = UIFont.systemFont(ofSize: 19.0);
    var errorColor = UIColor(hex: 0xe5466e);
    var successColor = UIColor(hex: 0x1ed7c5);
    var mainColor = UIColor(hex: 0x26a9e0);
    var backgroundColor = UIColor(hex: 0x00ccdd);
    var buttonBackgroundColor = UIColor(hex: 0xFFFFFF, alpha: 0.4);
}


/// Data set with values for PinController visual properties
/// All dataset properties have default values
struct AZPinDataSet {
    var blueprint = AZPinBlueprint();
    var vocab = AZPinVocabulary();
    var palette = AZPinPalette();
}
