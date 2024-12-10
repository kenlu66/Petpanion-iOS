//
//  Extensions.swift
//  Petpanion
//
//  Created by Ruolin Dong on 11/8/24.
//

import Foundation
import UIKit

// UIView extention for cleaner code
extension UIView {
    var width: CGFloat {
        frame.size.width
    }

    var height: CGFloat {
        frame.size.height
    }

    var left: CGFloat {
        frame.origin.x
    }

    var right: CGFloat {
        left + width
    }

    var top: CGFloat {
        frame.origin.y
    }

    var bottom: CGFloat {
        top + height
    }
}
