//
//  UIColor+AZPin.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
public extension UIColor {
    
    /// Method to create UIColor from rgb hex value
    ///
    /// - Parameters:
    ///   - hex: Hex value
    ///   - alpha: alpha value
    public convenience init(hex: Int, alpha: Float = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    public var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    public var components: [CGFloat] {
        let coreImageColor = self.coreImageColor
        return [coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha];
    }
    
    /// Calculates an average between 2 colors and gives new UIColor
    ///
    /// - Parameters:
    ///   - color1: First UIColor
    ///   - color2: Second UIColor
    /// - Returns: UIColor with new rgb value
    public static func averageColor(_ color1: UIColor, _ color2: UIColor) -> UIColor {
        let avgs = zip(color1.components, color2.components).map { [$0.0, $0.1].average };
        return UIColor(red: avgs[0], green: avgs[1], blue: avgs[2], alpha: avgs[3]);
    }
}
