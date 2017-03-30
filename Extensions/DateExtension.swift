//
//  DateExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension Date: NamespaceWrappable {}
extension NamespaceWrapper where T == Date {
    public static var millisecondTimestamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

}
