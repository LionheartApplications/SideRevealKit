//
//  SideMenuViewController.swift
//  SideRevealKit
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Shared Instance

extension SideRevealViewController {
    
    /// `SideRevealViewController` shared instance for the app.
    ///
    /// You can only have one instance of
    public static var shared: SideRevealViewController? {
        if let _shared = _shared { return _shared }
        return SideRevealViewController()
    }
    
    /// Internal memory location storing the `SideRevealViewController` for this app.
    static private var _shared: SideRevealViewController? {
        didSet {
            guard oldValue != nil else { return }
            assertionFailure("Instantiating more than one instance of SideMenuViewController in the app is not supported.")
        }
    }
}

// MARK: - Class Definition

/// `UIViewController` that is handling the reveal of view controller behind another one.
///
/// That is the main class in `SideRevealKit`. You can use it from storyboards or from code.
///
/// If you are using it from storyboards, you should set 'Relationship Segue's
/// to your front and side controllers for easier setup. Have a look at `SideRevealSegue` and `FrontRevealSegue`. for more info.
public final class SideRevealViewController: UIViewController {
    
    /// Property that controls how much the front(main) view controller is moved to the side on reveal.
    ///
    /// On this property depends how wide your container for side controller's view will be.
    @IBInspectable public var revealWidth: CGFloat = 250
    
    /// Property that controls how much time is needed for the front(main) view controller to move fully in order to reveal the side view controller.
    @IBInspectable public var revealDuration: TimeInterval = 0.7
    
    /// Property that controls the bounciness of the reveal action.
    @IBInspectable public var revealDamping: CGFloat = 0.8
    
    
    /// Property that holds reference to the side controller.
    private var sideController: UIViewController?
    
    /// Property that holds reference to the side controller's view container.
    ///
    /// It gets initialised on the first invocation of `sideContainer` computed variable.
    private var _sideContainer: UIView?
    
    
    /// Property that holds reference to the front controller.
    private var frontController: UIViewController?
    
    /// Property that holds reference to the front controller's view container.
    ///
    /// It gets initialised on the first invocation of `frontContainer` computed variable.
    private var _frontContainer: UIView?
    
    
    /// `NSLayoutConstraint` used for the animation of the reveal action.
    private var frontContainerCenterXConstraint: NSLayoutConstraint?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        guard storyboard != nil else { return }
        performSegue(withIdentifier: FrontRevealSegue.identifier, sender: nil)
        performSegue(withIdentifier: SideRevealSegue.identifier, sender: nil)
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        SideRevealViewController._shared = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        SideRevealViewController._shared = self
    }
}

// MARK: - Side View Controller

extension SideRevealViewController {
    
    /// `UIView` in which the side controller's view gets presented as a child.
    ///
    /// Use this view to tweak the appearance of the side view controller (think shadows, corner radiuses, `CGAffineTransform`-ations)
    public var sideContainer: UIView {
        guard _sideContainer == nil else { return _sideContainer! }
        loadViewIfNeeded()
        let menuContainer = UIView()
        menuContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuContainer)
        view.sendSubviewToBack(menuContainer)
        
        let top = NSLayoutConstraint(item: menuContainer, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: menuContainer, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: menuContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: menuContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: revealWidth)
        view.addConstraints([top, left, bottom, width])
        _sideContainer = menuContainer
        return menuContainer
    }
    
    /// Use this method to load the side view controller, that will get revealed on reveal action.
    ///
    /// You don't need to call this if you are using the storyboard segues `SideRevealSegue` and `FrontRevealSegue`.
    ///
    /// - Note: Calling this multiple times, will remove old controller and set the newly passed one.
    ///
    /// - Parameter viewController: the view controller you want revealed.
    public func loadSideFrom(_ viewController: UIViewController) {
        sideController?.removeFromParent()
        sideContainer.subviews.forEach { $0.removeFromSuperview() }
        embed(viewController, in: sideContainer)
    }
}

// MARK: - Front View Controller

extension SideRevealViewController {
    
    /// `UIView` in which the front(main) controller's view gets presented as a child.
    ///
    /// Use this view to tweak the appearance of the front(main) view controller (think shadows, corner radiuses, `CGAffineTransform`-ations)
    public var frontContainer: UIView {
        guard _frontContainer == nil else { return _frontContainer! }
        loadViewIfNeeded()
        let frontContainer = UIView()
        frontContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frontContainer)
        view.bringSubviewToFront(frontContainer)
        
        let top = NSLayoutConstraint(item: frontContainer, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let center = NSLayoutConstraint(item: frontContainer, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: frontContainer, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: frontContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, center, bottom, width])
        _frontContainer = frontContainer
        frontContainerCenterXConstraint = center
        return frontContainer
    }
    
    /// Use this method to load the front(main) view controller, that will get revealed on reveal action.
    ///
    /// You don't need to call this if you are using the storyboard segues `SideRevealSegue` and `FrontRevealSegue`.
    ///
    /// - Note: Calling this multiple times, will remove old controller and set the newly passed one.
    ///
    /// - Parameter viewController: the view controller you set as front(main).
    public func loadFrontFrom(_ viewController: UIViewController) {
        frontController?.removeFromParent()
        frontContainer.subviews.forEach { $0.removeFromSuperview() }
        embed(viewController, in: frontContainer)
    }
}

// MARK: - Reveal Side Menu

extension SideRevealViewController {
    
    /// Gives info whether the `SideRevealViewController` is currently in 'revealed' state.
    ///
    /// When the controller is in 'revealed' state, the side controller is visible.
    public var isRevealed: Bool { return frontContainerCenterXConstraint?.constant == revealWidth }
    
    /// Switches the current instance between 'reveal' and 'normal' state.
    @objc public func toggleReveal() { revealSide(!isRevealed, animated: true) }
    
    /// Use this method to reveal or hide the side view controller.
    ///
    /// - Parameters:
    ///   - reveal: if true, side controller is revealed.
    ///   - animated: if true, the reveal action is animated, no animation otherwise.
    public func revealSide(_ reveal: Bool, animated: Bool) {
        if animated {
            let animator = UIViewPropertyAnimator(duration: revealDuration, dampingRatio: revealDamping) { [weak self] in
                self?.revealSide(reveal)
            }
            animator.startAnimation()
        } else {
            revealSide(reveal)
        }
    }
    
    /// Method used internally to reveal or hide the side view controller.
    ///
    /// - Parameters:
    ///   - reveal: if true, side controller is revealed.
    private func revealSide(_ reveal: Bool) {
        frontContainerCenterXConstraint?.constant = reveal ? revealWidth : 0
        view.layoutIfNeeded()
    }
}
