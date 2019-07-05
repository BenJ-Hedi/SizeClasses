//
//  SizeClasses
//
//  Created by Hedi BEN JAHOUACH on 05/01/2019.
//  Copyright © 2019 BenJ.Hedi. All rights reserved.
//

import Foundation
import UIKit

public final class LayoutableView<Base: UIView> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol LayoutCompatible {
    associatedtype LayoutCompatibleType
    var layout: LayoutCompatibleType { get }
}

extension UIView: LayoutCompatible { }

extension LayoutCompatible where Self: UIView {
    public var layout: ConstraintCollection {
        return ConstraintCollection(self, constraints: [])
    }
}

public struct ConstraintCollection {
    private weak var view: UIView?
    private let constraints: [NSLayoutConstraint]
    public init(_ view: UIView, constraints: [NSLayoutConstraint]) {
        self.view = view
        view.translatesAutoresizingMaskIntoConstraints = false
        self.constraints = constraints
    }

    public func activate() {
        constraints.forEach { $0.isActive = true }
    }

    public func build() -> [NSLayoutConstraint] {
        return constraints
    }

    public func with(_ additionalConstraints: (UIView) -> [NSLayoutConstraint]) -> ConstraintCollection {
        guard let view = view else { return self }
        var constraints = self.constraints
        constraints.append(contentsOf: additionalConstraints(view))
        return ConstraintCollection(view, constraints: constraints)
    }
}

extension ConstraintCollection {
    public enum RelationMode {
        case equal
        case greaterThanOrEqual
        case lessThanOrEqual
    }
    
    public func fill(_ superview: UIView?, margin: UIEdgeInsets = .zero) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with {
            [
                $0.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin.top),
                $0.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -margin.right),
                $0.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin.bottom),
                $0.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margin.left)
            ]
        }
    }

    public func fillHorizontally(superview: UIView?, margin: UIEdgeInsets = .zero) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with {
            [
                $0.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -margin.right),
                $0.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margin.left)
            ]
        }
    }

    public func fillVertically(superview: UIView?, margin: UIEdgeInsets = .zero) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with {
            [
                $0.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin.top),
                $0.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin.bottom)
            ]
        }
    }

    public func center(in superview: UIView?) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with {
            [
                $0.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ]
        }
    }

    public func centerHorizontally(in superview: UIView?) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with { [$0.centerXAnchor.constraint(equalTo: superview.centerXAnchor)] }
    }

    public func centerVertically(in superview: UIView?) -> ConstraintCollection {
        guard let superview = superview else { return self }
        return with { [$0.centerYAnchor.constraint(equalTo: superview.centerYAnchor)] }
    }

    public func centerVertically(with view: UIView) -> ConstraintCollection {
        return with { [$0.centerYAnchor.constraint(equalTo: view.centerYAnchor)] }
    }

    public func followHorizontally(_ view: UIView?, spacing: CGFloat = 0.0, priority: UILayoutPriority = .required, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        return with {
            let constraint: NSLayoutConstraint
            switch relationMode {
            case .equal: constraint = $0.leftAnchor.constraint(equalTo: view.rightAnchor, constant: spacing)
            case .greaterThanOrEqual: constraint = $0.leftAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: spacing)
            case .lessThanOrEqual: constraint = $0.leftAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: spacing)
            }
            constraint.priority = priority
            return [constraint]
        }
    }

    public func precedeHorizontally(_ view: UIView?, spacing: CGFloat = 0.0, priority: UILayoutPriority = .required) -> ConstraintCollection {
        guard let view = view else { return self }
        return with {
            let constraint = $0.rightAnchor.constraint(equalTo: view.leftAnchor, constant: -spacing)
            constraint.priority = priority
            return [constraint]
        }
    }

    public func followVertically(_ view: UIView?, spacing: CGFloat = 0.0, priority: UILayoutPriority = .required) -> ConstraintCollection {
        guard let view = view else { return self }
        return with {
            let constraint = $0.topAnchor.constraint(equalTo: view.bottomAnchor, constant: spacing)
            constraint.priority = priority
            return [constraint]
        }
    }

    public func pinLeft(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        switch relationMode {
        case .equal:
            return with { [$0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin)] }
        case .greaterThanOrEqual:
            return with { [$0.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: margin)] }
        case .lessThanOrEqual:
            return with { [$0.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor, constant: margin)] }
        }
    }

    public func pinRight(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        switch relationMode {
        case .equal:
            return with { [$0.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin)] }
        case .greaterThanOrEqual:
            return with { [$0.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -margin)] }
        case .lessThanOrEqual:
            return with { [$0.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: -margin)] }
        }
    }

    public func pinTop(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        switch relationMode {
        case .equal:
            return with { [$0.topAnchor.constraint(equalTo: view.topAnchor, constant: margin)] }
        case .greaterThanOrEqual:
            return with { [$0.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: margin)] }
        case .lessThanOrEqual:
            return with { [$0.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: margin)] }
        }
    }

    public func pinAsLeftBarButtonItem(to view: UIView?) -> ConstraintCollection {
        guard let view = view else { return self }
        return with {
            [
                $0.centerYAnchor.constraint(equalTo: view.compatibleSafeLayoutGuideTopAnchor, constant: 22.0),
                $0.leftAnchor.constraint(equalTo: view.compatibleSafeLayoutGuideLeftAnchor, constant: Constants.margin)
            ]
        }
    }

    public func pinAsRightBarButtonItem(to view: UIView?) -> ConstraintCollection {
        guard let view = view else { return self }
        return with {
            [
                $0.centerYAnchor.constraint(equalTo: view.compatibleSafeLayoutGuideTopAnchor, constant: 22.0),
                $0.rightAnchor.constraint(equalTo: view.compatibleSafeLayoutGuideRightAnchor, constant: -Constants.margin)
            ]
        }
    }

    public func pinSafeTop(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        let anchor: NSLayoutYAxisAnchor
        let compatibleSafeMargin: CGFloat
        if #available(iOS 11.0, *) {
            anchor = view.safeAreaLayoutGuide.topAnchor
            compatibleSafeMargin = 0
        } else {
            anchor = view.topAnchor
            compatibleSafeMargin = view.compatibleSafeAreaInsets.top
        }
        
        switch relationMode {
        case .equal:
            return with { [$0.topAnchor.constraint(equalTo: anchor, constant: margin + compatibleSafeMargin)] }
        case .greaterThanOrEqual:
            return with { [$0.topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: margin + compatibleSafeMargin)] }
        case .lessThanOrEqual:
            return with { [$0.topAnchor.constraint(lessThanOrEqualTo: anchor, constant: margin + compatibleSafeMargin)] }
        }
    }

    public func pinSafeBottom(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        let anchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            anchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            anchor = view.bottomAnchor
        }
        
        switch relationMode {
        case .equal:
            return with { [$0.bottomAnchor.constraint(equalTo: anchor, constant: -margin)] }
        case .greaterThanOrEqual:
            return with { [$0.bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: -margin)] }
        case .lessThanOrEqual:
            return with { [$0.bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -margin)] }
        }
    }

    public func pinSafeLeft(to view: UIView?, margin: CGFloat = 0.0) -> ConstraintCollection {
        guard let view = view else { return self }
        if #available(iOS 11.0, *) {
            return with { [$0.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: margin)] }
        } else {
            return with { [$0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin)] }
        }
    }

    public func pinSafeRight(to view: UIView?, margin: CGFloat = 0.0) -> ConstraintCollection {
        guard let view = view else { return self }
        if #available(iOS 11.0, *) {
            return with { [$0.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -margin)] }
        } else {
            return with { [$0.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin)] }
        }
    }

    public func pinBottom(to view: UIView?, margin: CGFloat = 0.0, relationMode: RelationMode = .equal) -> ConstraintCollection {
        guard let view = view else { return self }
        switch relationMode {
        case .equal:
            return with { [$0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)] }
        case .greaterThanOrEqual:
            return with { [$0.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -margin)] }
        case .lessThanOrEqual:
            return with { [$0.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -margin)] }
        }
    }

    public func respectWidthToHeightRatio(of value: CGFloat) -> ConstraintCollection {
        return with { [$0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: value)] }
    }

    public func respectHeightToWidthRatio(of value: CGFloat) -> ConstraintCollection {
        return with { [$0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: value)] }
    }

    public func setWidth(_ value: CGFloat) -> ConstraintCollection {
        return with { [$0.widthAnchor.constraint(equalToConstant: value)] }
    }

    public func setHeight(_ value: CGFloat) -> ConstraintCollection {
        return with { [$0.heightAnchor.constraint(equalToConstant: value)] }
    }

    public func setSize(_ value: CGSize) -> ConstraintCollection {
        return with {
            [
                $0.heightAnchor.constraint(equalToConstant: value.height),
                $0.widthAnchor.constraint(equalToConstant: value.width)
            ]
        }
    }

    public func equalWidth(to view: UIView, multiplier: CGFloat = 1.0) -> ConstraintCollection {
        return with { [$0.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)] }
    }
}
