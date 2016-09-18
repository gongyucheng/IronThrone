//
//  UIViewExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit

extension IronThrone where Base: UIView {
    /**
     移除所有子视图
     */
    public func removeAllSubViews() {
        base.subviews.forEach { (subView) -> () in
            subView.removeFromSuperview()
        }
    }

    
}
