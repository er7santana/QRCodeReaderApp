//
//  UIView+Extension.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 23/06/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

extension UIView {
    public func addSubview<T: UIView>(_ view: T, affectedViews: [T] = [], constraints: [NSLayoutConstraint]) {
        addSubview(view, affectedViews: affectedViews)
        NSLayoutConstraint.activate(constraints)
    }

    func addSubview<T: UIView>(_ view: T, affectedViews: [T] = [], _ viewBuilder: (T) -> Void) {
        addSubview(view, affectedViews: affectedViews)

        viewBuilder(view)
    }

    public func addSubview<T: UIView>(equalConstraintsFor view: T, withMargin margin: CGFloat = 0, affectedViews: [T] = []) {
        addSubview(view, affectedViews: affectedViews, constraints: [
            view.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ])
    }

    func addSubview<T: UIView>(_ view: T, autoresizingMask: UIView.AutoresizingMask) {
        addSubview(view)

        view.autoresizingMask = autoresizingMask
    }

    @discardableResult
    public func anchored() -> Self {
        translatesAutoresizingMaskIntoConstraints = false

        return self
    }

    // MARK: Private functions

    private func addSubview<T: UIView>(_ view: T, affectedViews: [T]) {
        addSubview(view)

        [affectedViews + [view]].flatMap(Set.init).forEach { view in
            view.anchored()
        }
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    public func removeAllConstraints() {
        var _superview = self.superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func addoverlay(color: UIColor = .black,alpha : CGFloat = 0.5) {
        let overlay = UIView()
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.frame = bounds
        overlay.backgroundColor = color
        overlay.alpha = alpha
        addSubview(overlay)
    }
}
