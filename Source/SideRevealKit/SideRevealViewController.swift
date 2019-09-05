//
//  SideMenuViewController.swift
//  SideRevealKit
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Tags

extension Int {
    
    /// Tag used in `SideRevealViewController` for searching for the `frontContainer`s overlay view.
    static fileprivate let overlayTag = 13432
}

// MARK: - Shared Instance

extension SideRevealViewController {
    
    /// `SideRevealViewController` shared instance for the app.
    ///
    /// You can only have one instance of
    public static var shared: SideRevealViewController {
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
    
    
    
    // MARK: Public Settings
    
    /// Property that controls how much the front(main) view controller is moved to the side on reveal.
    ///
    /// On this property depends how wide your container for side controller's view will be.
    @IBInspectable public var revealWidth: CGFloat = 250
    
    /// Property that controls how much time is needed for the front(main) view controller to move fully in order to reveal the side view controller.
    @IBInspectable public var revealDuration: TimeInterval = 0.7
    
    /// Property that controls the bounciness of the reveal action.
    @IBInspectable public var revealDamping: CGFloat = 0.8
    
    /// Used to set the color of the overlay that hides the front view on reveal.
    @IBInspectable public var frontOverlayColor: UIColor = .clear { didSet { DispatchQueue.main.async { [weak self] in self?.overlayView?.backgroundColor = self?.frontOverlayColor }}}
    
    /// Used to set the alpha level of the overlay that hides the front view on reveal.
    @IBInspectable public var frontOverlayAlpha: CGFloat = 0.7 { didSet { overlayView?.alpha = frontOverlayAlpha }}
    
    /// This enables/disables the swipe to reveal gesture.
    @IBInspectable public var revealOnSwipe = true { didSet { DispatchQueue.main.async { [weak self] in self?.scrollView.isScrollEnabled = self?.revealOnSwipe ?? true }}}
    
    /// Set here object who wants to get notified when reveal state is changing.
    public weak var delegate: SideRevealViewControllerDelegate?
    
    /// Property that holds reference to the side controller.
    public var sideController: UIViewController?
    
    /// Property that holds reference to the front controller.
    public var frontController: UIViewController?
    
    
    
    // MARK: Internal Properties
    
    /// Property that holds reference to the side controller's view container.
    ///
    /// It gets initialised on the first invocation of `sideContainer` computed variable.
    private var _sideContainer: UIView?
    
    /// Property that holds reference to the front controller's view container.
    ///
    /// It gets initialised on the first invocation of `frontContainer` computed variable.
    private var _frontContainer: UIView?
    
    /// Property that holds reference to the front controller's scroll view, that has the front container in its content.
    ///
    /// It gets initialised on the first invocation of `frontContainer` computed variable.
    private var _scrollView: TouchContentScrollView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        guard storyboard != nil else { return }
        performSegue(withIdentifier: FrontRevealSegue.identifier, sender: nil)
        performSegue(withIdentifier: SideRevealSegue.identifier, sender: nil)
    }
    
    
    
    
    // MARK: Initialisers
    
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
        view.layoutIfNeeded()
        let menuContainer = UIView()
        menuContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuContainer)
        view.sendSubviewToBack(menuContainer)
        
        let top = NSLayoutConstraint(item: menuContainer, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: menuContainer, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: menuContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: menuContainer, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -(view.bounds.width - revealWidth))
        view.addConstraints([top, left, bottom, right])
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
        sideController = viewController
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
        view.layoutIfNeeded()
        let scrollView = TouchContentScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.bringSubviewToFront(scrollView)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = revealOnSwipe
        
        let top = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, left, bottom, right])
        
        
        let frontContainer = UIView()
        frontContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(frontContainer)
        
        let innerTop = NSLayoutConstraint(item: frontContainer, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        let innerLeft = NSLayoutConstraint(item: frontContainer, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0)
        let innerRight = NSLayoutConstraint(item: frontContainer, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1, constant: 0)
        let innerBottom = NSLayoutConstraint(item: frontContainer, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: frontContainer, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: frontContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        scrollView.addConstraints([innerTop, innerLeft, innerRight, innerBottom])
        view.addConstraints([width, height])
        scrollView.contentSize = view.bounds.size
        scrollView.contentInset = UIEdgeInsets(top: 0, left: revealWidth, bottom: 0, right: 0)
        
        _frontContainer = frontContainer
        _scrollView = scrollView
        prepareOverlayViewFor(frontContainer)
        return frontContainer
    }
    
    /// Reference to the `TouchContentScrollView` that contains the front container.
    private var scrollView: TouchContentScrollView {
        guard _scrollView == nil else { return _scrollView! }
        
        // in the front container getter _scrollView MUST be initialised
        _ = frontContainer
        return _scrollView!
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
        frontController = viewController
    }
}

// MARK: - Front Overlay Controller

extension SideRevealViewController {
    
    /// Reference to the top overlay view in front of the main controller. Available only after frontContainer is initialised.
    public var overlayView: UIView? { return view.viewWithTag(.overlayTag) }
    
    /// Puts overlay view on top of the passed view. Used for `frontContainer`.
    ///
    /// - Parameter frontView: pass here the view you want overlay put on top.
    private func prepareOverlayViewFor(_ frontView: UIView) {
        
        let overlay = UIView(frame: .zero)
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.tag = .overlayTag
        overlay.backgroundColor = frontOverlayColor
        overlay.isUserInteractionEnabled = false
        overlay.alpha = 0
        
        let top = NSLayoutConstraint(item: frontView, attribute: .top, relatedBy: .equal, toItem: overlay, attribute: .top, multiplier: 1, constant: 0)
        let center = NSLayoutConstraint(item: frontView, attribute: .centerX, relatedBy: .equal, toItem: overlay, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: frontView, attribute: .width, relatedBy: .equal, toItem: overlay, attribute: .width, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: frontView, attribute: .bottom, relatedBy: .equal, toItem: overlay, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, center, bottom, width])
    }
}

// MARK: - Reveal Side Menu

extension SideRevealViewController {
    
    /// Gives info whether the `SideRevealViewController` is currently in 'revealed' state.
    ///
    /// When the controller is in 'revealed' state, the side controller is visible.
    public var isRevealed: Bool { return scrollView.contentOffset.x == -revealWidth }
    
    /// Switches the current instance between 'reveal' and 'normal' state.
    @objc public func toggleReveal() { revealSide(!isRevealed, animated: true) }
    
    /// Use this method to reveal or hide the side view controller.
    ///
    /// - Parameters:
    ///   - reveal: if true, side controller is revealed.
    ///   - animated: if true, the reveal action is animated, no animation otherwise.
    public func revealSide(_ reveal: Bool, animated: Bool) {
        delegate?.sideRevealViewController?(self, willReveal: reveal, animated: animated)
        if animated {
            let animator = UIViewPropertyAnimator(duration: revealDuration, dampingRatio: revealDamping) { [weak self] in
                self?.revealSide(reveal)
                self?.showOverlay(reveal)
            }
            animator.startAnimation()
        } else {
            revealSide(reveal)
            showOverlay(reveal, animated: false)
        }
    }
    
    /// Method used internally to reveal or hide the side view controller.
    ///
    /// - Parameters:
    ///   - reveal: if true, side controller is revealed.
    private func revealSide(_ reveal: Bool) {
        let contentOffset = CGPoint(x: reveal ? -revealWidth : 0, y: scrollView.contentOffset.y)
        scrollView.setContentOffset(contentOffset, animated: false)
        view.layoutIfNeeded()
    }
    
    /// Method used internally to show or hide the overlay view of the front container.
    ///
    /// - Parameters:
    ///   - reveal: if true, overlay is shown.
    ///   - animated: if true, the transition is animated, no animation otherwise.
    private func showOverlay(_ reveal: Bool, animated: Bool = true) {
        if animated {
            let animator = UIViewPropertyAnimator(duration: revealDuration, dampingRatio: revealDamping) { [weak self] in
                self?.showOverlay(reveal)
            }
            animator.startAnimation()
        } else {
           showOverlay(reveal)
        }
    }
    
    /// Method used internally to show or hide the overlay view of the front container.
    ///
    /// - Parameters:
    ///   - reveal: if true, overlay is shown.
    private func showOverlay(_ reveal: Bool) {
        overlayView?.alpha = reveal ? frontOverlayAlpha : 0
    }
}

// MARK: - Swipe To Reveal

extension SideRevealViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let targetX = scrollView.contentOffset.x
        let willBeRevealed = targetX > -(view.bounds.width - revealWidth / 10)
        
        if willBeRevealed {
            showOverlay(false, animated: true)
        }
        
        if scrollView.isDragging {
            if scrollView.contentOffset.x > -(revealWidth / 2) {
                scrollView.bounces = false
            }
            if scrollView.contentOffset.x < -(revealWidth / 2) {
                scrollView.bounces = true
            }
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetX = targetContentOffset.pointee.x
        let willBeRevealed = targetX > -(revealWidth / 2)

        guard targetX > -revealWidth && targetX < 0 else { return }
        targetContentOffset.pointee.x = willBeRevealed ? 0 : -revealWidth
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        revealSide(scrollView.contentOffset.x < -(revealWidth / 2), animated: true)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        revealSide(scrollView.contentOffset.x < -(revealWidth / 2), animated: true)
    }
}
