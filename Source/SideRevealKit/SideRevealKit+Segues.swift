//
//  SideRevealKit+Segues.swift
//  SideRevealKit
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Segues

/// Relationship Segue, used to set the side view controller of `SideRevealViewController`.
///
/// set this in storyboard's segue identier field
/// ```
/// "SideRevealKit-Side"
/// ```
public final class SideRevealSegue: UIStoryboardSegue {
    
    /// The identifier that has to be set to this segue,
    /// if you want to use it from storyboards
    ///
    /// set this in storyboard's segue identier field
    /// ```
    /// "SideRevealKit-Side"
    /// ```
    public static let identifier = "SideRevealKit-Side"
    
    override public func perform() {
        (source as? SideRevealViewController)?.loadSideFrom(destination)
    }
}

/// Relationship Segue, used to set the front(main) view controller of `SideRevealViewController`.
///
/// set this in storyboard's segue identier field
/// ```
/// "SideRevealKit-Front"
/// ```
public final class FrontRevealSegue: UIStoryboardSegue {
    
    /// The identifier that has to be set to this segue,
    /// if you want to use it from storyboards
    ///
    /// set this in storyboard's segue identier field
    /// ```
    /// "SideRevealKit-Front"
    /// ```
    public static let identifier = "SideRevealKit-Front"
    
    override public func perform() {
        (source as? SideRevealViewController)?.loadFrontFrom(destination)
    }
}
