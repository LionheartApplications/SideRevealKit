//
//  UIViewController+Embed.swift
//  SideRevealKit
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Embedding View Controllers

extension UIViewController {
    
    /// Embeds easily a view controller inside this one. if called multiple time **pay attention to call** `children.forEach { $0.removeFromParent() }` **when appropriate**
    ///
    /// In case you are not sure when you call this method and whether the view controller is already loaded invoke first `_ = view` to force load the view.
    ///
    /// - Parameters:
    ///   - viewController: the view controller you want to embed.
    ///   - containerView: the view in which you want your view controller visible.
    func embed(_ viewController: UIViewController, in containerView: UIView?) {
        guard let containerView = containerView else { return }
        guard let view = viewController.view else { return }
        addChild(viewController)
        
        containerView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let top   = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
        let left  = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1, constant: 0)
        let down  = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
        
        containerView.addConstraints([top, left, right, down])
        viewController.didMove(toParent: self)
    }
}
