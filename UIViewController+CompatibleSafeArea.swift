//
//  SizeClasses
//
//  Created by Hedi BEN JAHOUACH on 05/01/2019.
//  Copyright © 2019 BenJ.Hedi. All rights reserved.
//

import UIKit

private func statusBarFrame() -> CGRect {
    if #available(iOS 11.0, *) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            return UIApplication.shared.statusBarFrame
        } else {
            return CGRect(x: UIApplication.shared.statusBarFrame.origin.y,
                          y: UIApplication.shared.statusBarFrame.origin.x,
                          width: UIApplication.shared.statusBarFrame.size.height,
                          height: UIApplication.shared.statusBarFrame.size.width)
        }
    } else {
        return UIApplication.shared.statusBarFrame
    }
}

public extension UIView {
    private enum Keys {
        static var compatibleSafeTopLayoutGuide = "compatibleSafeTopLayoutGuide"
    }

    /// This creates a fake UILayoutGuide 20 point height from the top of the screen, simulating a status bar
    private func createCompatibleSafeTopLayoutGuide() -> UILayoutGuide {
        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        let currentStatusBarFrame = statusBarFrame()
        layoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        layoutGuide.heightAnchor.constraint(equalToConstant: currentStatusBarFrame.height).isActive = true
        return layoutGuide
    }

    private var _compatibleSafeTopLayoutGuide: UILayoutGuide? {
        get {
            return objc_getAssociatedObject(self, &Keys.compatibleSafeTopLayoutGuide) as? UILayoutGuide
        }
        set {
            objc_setAssociatedObject(self, &Keys.compatibleSafeTopLayoutGuide, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var compatibleSafeTopLayoutGuide: UILayoutGuide {
        if let compatibleSafeTopLayoutGuide = _compatibleSafeTopLayoutGuide {
            return compatibleSafeTopLayoutGuide
        }
        let compatibleSafeTopLayoutGuide = createCompatibleSafeTopLayoutGuide()
        _compatibleSafeTopLayoutGuide = compatibleSafeTopLayoutGuide
        return compatibleSafeTopLayoutGuide
    }

    var compatibleSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            guard let window = UIApplication.shared.keyWindow else { return UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0) }
            let currentStatusBarFrame = statusBarFrame()
            guard currentStatusBarFrame.size != CGSize.zero else { return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
            let frameInSelf = convert(currentStatusBarFrame, from: window)
            return UIEdgeInsets(top: max(0, frameInSelf.maxY), left: 0, bottom: 0, right: 0)
        }
    }

    var compatibleSafeLayoutGuideTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return compatibleSafeTopLayoutGuide.bottomAnchor
        }
    }

    var compatibleSafeLayoutGuideRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        } else {
            return rightAnchor
        }
    }

    var compatibleSafeLayoutGuideBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }

    var compatibleSafeLayoutGuideLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        } else {
            return leftAnchor
        }
    }

    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            return (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) > 20.0
        } else {
            return false
        }
    }
}
