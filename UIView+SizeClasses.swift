//
//  SizeClasses
//
//  Created by Hedi BEN JAHOUACH on 05/01/2019.
//  Copyright © 2019 BenJ.Hedi. All rights reserved.
//

import Foundation
import UIKit

private enum UIContentContainerSizeClassHelpersKeys {
    static var sizeClassBasedConstraints: UInt8 = 0
    static var willTransitionToNewTraitCollectionListeners: UInt8 = 0
    static var traitCollectionDidChangeListeners: UInt8 = 0
}

public struct ResolutionSizeClasses: Hashable {
    public let horizontal: UIUserInterfaceSizeClass
    public let vertical: UIUserInterfaceSizeClass
    
    public init(traitCollection: UITraitCollection) {
        self.horizontal = traitCollection.horizontalSizeClass
        self.vertical = traitCollection.verticalSizeClass
    }
    
    public init(_ horizontal: UIUserInterfaceSizeClass, _ vertical: UIUserInterfaceSizeClass) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public static var `default`: ResolutionSizeClasses {
        return ResolutionSizeClasses(.unspecified, .unspecified)
    }
    
    public static var regularWidth: ResolutionSizeClasses {
        return ResolutionSizeClasses(.regular, .unspecified)
    }
}

public extension UITraitCollection {
    public func resolutionSizeClasses() -> ResolutionSizeClasses {
        return ResolutionSizeClasses(traitCollection: self)
    }
}

private extension Dictionary where Key == ResolutionSizeClasses, Value == [NSLayoutConstraint] {
    func toggle(using traitCollection: UITraitCollection) {
        func isMoreSpecificThan(a: ResolutionSizeClasses, b: ResolutionSizeClasses) -> Bool {
            if a.horizontal != .unspecified && a.vertical != .unspecified {
                return true
            }
            if a.horizontal == .unspecified && a.vertical == .unspecified {
                return false
            }
            if b.horizontal != .unspecified && b.vertical != .unspecified {
                return false
            }
            if b.horizontal == .unspecified && b.vertical == .unspecified {
                return true
            }
            return true
        }
        
        let sizeClassesSorted = sorted { (keyValues1, keyValues2) -> Bool in
            return isMoreSpecificThan(a: keyValues1.key, b: keyValues2.key)
        }
        
        var isSpecificMatcherFound = false
        sizeClassesSorted.forEach { (key, value) in
            switch (key.horizontal, key.vertical) {
            case (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass):
                isSpecificMatcherFound = true
                value.forEach { $0.isActive = true }
            case (_, .unspecified) where traitCollection.horizontalSizeClass == .unspecified:
                isSpecificMatcherFound = true
                value.forEach { $0.isActive = true }
            case (.unspecified, _) where traitCollection.verticalSizeClass == .unspecified:
                isSpecificMatcherFound = true
                value.forEach { $0.isActive = true }
            case (.unspecified, traitCollection.verticalSizeClass):
                isSpecificMatcherFound = true
                value.forEach { $0.isActive = true }
            case (traitCollection.horizontalSizeClass, .unspecified):
                isSpecificMatcherFound = true
                value.forEach { $0.isActive = true }
            case (.unspecified, .unspecified) where !isSpecificMatcherFound:
                value.forEach { $0.isActive = true }
            default:
                value.forEach { $0.isActive = false }
            }
        }
    }
}

public typealias SizeClassBasedConstraints = [ResolutionSizeClasses: [NSLayoutConstraint]]
public typealias SizeClassBasedConstraintCollections = [ResolutionSizeClasses: [ConstraintCollection]]

public extension UITraitEnvironment {
    private var sizeClassBasedConstraints: [SizeClassBasedConstraints]? {
        set {
            objc_setAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.sizeClassBasedConstraints, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.sizeClassBasedConstraints) as? [SizeClassBasedConstraints]
        }
    }
    
    public func install(sizeClassConstraintCollections: SizeClassBasedConstraintCollections) {
        let newConstraints = sizeClassConstraintCollections.mapValues { $0.flatMap { $0.build() } }
        install(sizeClassConstraints: newConstraints)
    }
    
    public func install(sizeClassConstraints: SizeClassBasedConstraints) {
        var currentConstraints = sizeClassBasedConstraints ?? []
        currentConstraints.append(sizeClassConstraints)
        sizeClassBasedConstraints = currentConstraints
    }
    
    public func applySizeClassConstraints(for traitCollection: UITraitCollection) {
        guard let sizeClasses = sizeClassBasedConstraints else { return }
        sizeClasses.forEach { $0.toggle(using: traitCollection) }
    }

    public var isUserInterfaceSizeClassesRegular: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
}

public protocol SizeClassConstraintsProviding {
    func viewsToApplySizeClassConstraints() -> [UIView]
}

extension UIView {
    public func hideForCompactSizeClassesTraitCollection() {
        isHidden = !isUserInterfaceSizeClassesRegular
    }

    public func hideForRegularSizeClassesTraitCollection() {
        isHidden = isUserInterfaceSizeClassesRegular
    }
}

extension BaseViewController {
    private var willTransitionToNewTraitCollectionListener: ((UITraitCollection, UIViewControllerTransitionCoordinator) -> ())? {
        set {
            objc_setAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.willTransitionToNewTraitCollectionListeners, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.willTransitionToNewTraitCollectionListeners) as? ((UITraitCollection, UIViewControllerTransitionCoordinator) -> ())
        }
    }
    
    private var traitCollectionDidChangeListener: ((UITraitCollection?) -> ())? {
        set {
            objc_setAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.traitCollectionDidChangeListeners, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UIContentContainerSizeClassHelpersKeys.traitCollectionDidChangeListeners) as? ((UITraitCollection?) -> ())
        }
    }
    
    public func install(sizeClassConstraintCollections: SizeClassBasedConstraintCollections) {
        view.install(sizeClassConstraintCollections: sizeClassConstraintCollections)
        subscribeToListeners()
    }
    
    public func install(sizeClassConstraints: SizeClassBasedConstraints) {
        view.install(sizeClassConstraints: sizeClassConstraints)
        subscribeToListeners()
    }
    
    private func subscribeToListeners() {
        if willTransitionToNewTraitCollectionListener == nil {
            let listener: ((UITraitCollection, UIViewControllerTransitionCoordinator) -> ()) = { [weak self] traitCollection, coordinator in
                coordinator.animate(alongsideTransition: { _ in
                    self?.applySizeClassConstraints(for: traitCollection)
                }, completion: nil)
            }
            willTransitionToNewTraitCollectionListener = listener
            addWillTransitionToNewTraitCollectionListeners(callback: listener)
        }
        
        if traitCollectionDidChangeListener == nil {
            let listener: ((UITraitCollection?) -> ()) = { [weak self] _ in
                guard let self = self else { return }
                self.applySizeClassConstraints(for: self.traitCollection)
            }
            traitCollectionDidChangeListener = listener
            addTraitCollectionDidChangeListeners(callback: listener)
        }
    }
    
    public func applySizeClassConstraints(for traitCollection: UITraitCollection) {
        view.applySizeClassConstraints(for: traitCollection)
        if let provider = self as? SizeClassConstraintsProviding {
            provider.viewsToApplySizeClassConstraints().forEach { $0.applySizeClassConstraints(for: traitCollection) }
        }
    }
}
