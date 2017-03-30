//
//  UIViewExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit

extension UIView: NamespaceWrappable {}
extension NamespaceWrapper where T: UIView {
    
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = wrappedValue
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    /**
     移除所有子视图
     */
    public func removeAllSubViews() {
        wrappedValue.subviews.forEach { (subView) -> () in
            subView.removeFromSuperview()
        }
    }

    
}
