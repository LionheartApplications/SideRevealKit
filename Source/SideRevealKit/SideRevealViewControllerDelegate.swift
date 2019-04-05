//
//  SideRevealViewControllerDelegate.swift
//  SideRevealKit
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import Foundation

/// Set of all callbacks for reveal state switching of `SideRevealViewController`.
///
/// If you want to receive those, set yourself as delegate of the `SideRevealViewController`.
@objc public protocol SideRevealViewControllerDelegate: AnyObject {
    
    /// Called when `SideRevealViewController` is about to switch its state.
    ///
    /// - Parameters:
    ///   - sideRevealViewController: reference to the `SideRevealViewController`.
    ///   - reveal: true if side controller will be shown, false if it will be hidden.
    ///   - animated: true if reveal action will be animated, false if not.
    @objc optional func sideRevealViewController(_ sideRevealViewController: SideRevealViewController, willReveal reveal: Bool, animated: Bool)
}
