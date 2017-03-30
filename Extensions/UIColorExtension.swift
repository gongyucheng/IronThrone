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

        var colorText = hex
            .lowercased()
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        switch colorText {
        case let text where text.hasPrefix("0x"):
            colorText = text.substring(from: text.characters.index(text.startIndex, offsetBy: 2))

        case let text where text.hasPrefix("#"):
            colorText = text.substring(from: text.characters.index(text.startIndex, offsetBy: 1))
        default:
            break
        }

        guard colorText.characters.count == 6 else {
            return defaultColor
        }

        // TODO: 下面这段代码应该是可以优化的
        var startIndex = colorText.startIndex
        var endIndex = colorText.characters.index(startIndex, offsetBy: 2)

        let rString = colorText.substring(with: Range(uncheckedBounds: (startIndex, endIndex)))

        startIndex = endIndex
        endIndex = colorText.characters.index(startIndex, offsetBy: 2)

        let gString = colorText.substring(with: Range(uncheckedBounds: (startIndex, endIndex)))

        startIndex = endIndex
        endIndex = colorText.characters.index(startIndex, offsetBy: 2)

        let bString = colorText.substring(with: Range(uncheckedBounds: (startIndex, endIndex)))

        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        Scanner(string: rString as String).scanHexInt32(&r)
        Scanner(string: gString as String).scanHexInt32(&g)
        Scanner(string: bString as String).scanHexInt32(&b)

        return T(red: CGFloat(r) / 255.0
            , green: CGFloat(g) / 255.0
            , blue: CGFloat(b) / 255.0
            , alpha: alphaValue)
    }
}
