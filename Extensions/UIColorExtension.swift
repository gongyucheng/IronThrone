//
//  UIColorExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit

extension UIColor: NamespaceWrappable {}
extension NamespaceWrapper where T: UIColor {

    /**
     创建十六进制文本表示的 UIColor

     - parameter hex:           代表颜色的16进制文本
     - parameter alpha:         alpha 值，范围 [0.0, 1.0]

     - returns: 对应的 UIColor 对象
     */
    public static func color(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let defaultColor = UIColor.white

        let alphaValue: CGFloat
        if alpha > 1.0 || alpha < 0.0 {
            alphaValue = 1.0
        } else {
            alphaValue = alpha
        }

        var hexColorText = hex
            .lowercased()
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        switch hexColorText {
        case let text where text.hasPrefix("0x"):
            hexColorText = text.irt.substring(from: 2)

        case let text where text.hasPrefix("#"):
            hexColorText = text.irt.substring(from: 1)
        default:
            break
        }

        guard hexColorText.irt.match(regex: "[0-9a-f]{6}") else {
            return defaultColor
        }


        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0

        guard Scanner(string: hexColorText.irt.substring(with: 0..<2)).scanHexInt32(&r)
            , Scanner(string: hexColorText.irt.substring(with: 2..<4)).scanHexInt32(&g)
            , Scanner(string: hexColorText.irt.substring(with: 4..<6)).scanHexInt32(&b)
            else {
                return defaultColor
        }

        return UIColor(red: CGFloat(r) / 255.0
            , green: CGFloat(g) / 255.0
            , blue: CGFloat(b) / 255.0
            , alpha: alphaValue)
    }
}
