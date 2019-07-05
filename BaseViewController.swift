//
//  BaseViewController.swift
//  HappnMeteo
//
//  Created by Hedi BEN JAHOUACH on 05/07/2019.
//  Copyright © 2019 BenJ.Hedi. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, Storyboard {

    private var viewDidLoadListeners = [() -> ()]()
    private var viewWillAppearListeners = [(Bool) -> ()]()
    private var viewWillDisappearListeners = [(Bool) -> ()]()
    private var willTransitionToNewTraitCollectionListeners = [(UITraitCollection, UIViewControllerTransitionCoordinator) -> ()]()
    private var traitCollectionDidChangeListeners = [(UITraitCollection?) -> ()]()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadListeners.forEach { $0() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearListeners.forEach { $0(animated) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearListeners.forEach { $0(animated) }
    }

    func addViewDidLoadListener(callback: @escaping () -> ()) {
        viewDidLoadListeners.append(callback)
    }

    func addViewWillAppearListener(callback: @escaping (Bool) -> ()) {
        viewWillAppearListeners.append(callback)
    }

    func addViewWillDisappearListener(callback: @escaping (Bool) -> ()) {
        viewWillDisappearListeners.append(callback)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionDidChangeListeners.forEach { $0(previousTraitCollection) }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        willTransitionToNewTraitCollectionListeners.forEach { $0(newCollection, coordinator) }
    }

    func addWillTransitionToNewTraitCollectionListeners(callback: @escaping (UITraitCollection, UIViewControllerTransitionCoordinator) -> ()) {
        willTransitionToNewTraitCollectionListeners.append(callback)
    }

    func addTraitCollectionDidChangeListeners(callback: @escaping (UITraitCollection?) -> ()) {
        traitCollectionDidChangeListeners.append(callback)
    }
}
