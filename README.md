

# SideRevealKit
![](https://img.shields.io/badge/version-1.0-brightgreen.svg)

SideRevealKit is iOS Dynamic Framework for presenting `UIViewController`'s on the left side behing another `UIViewController`. It is perfect for implementing side menus and at the same time minimalistic in its implementation. It provides the basic behaviour while leaving you to do the UI cistomizations, which sets it apart from libraries that provide the same functionality with many different styles already contained in the library. If you don't want to have reveal styles and code that is unused in your app, then this implementation is right for you.

Build using Swift 5, XCode 10.2, supports iOS 10.0+

# Preview

![](https://raw.githubusercontent.com/stoqn4opm/SideRevealKit/master/Preview/SideRevealKit-preview.gif)

# Usage

You can use **SideRevealKit** from code and from storyboards.

- setup from code:
	 - in your `AppDelegate`  `import SideRevealKit`
	- in your `AppDelegate` `applicationDidFinishLaunching` method add:
	``` swift
	window?.rootViewController = SideRevealViewController.shared

	// replace the paramater with your view controller 
	SideRevealViewController.shared.loadSideFrom(UITableViewController())
	
	// replace the paramater with your view controller
	SideRevealViewController.shared.loadFrontFrom(UIViewController())
	```
	- When you want to reveal the side controller, you can call either: `SideRevealViewController.shared.toggleReveal()` or `SideRevealViewController.shared.revealSide(_ reveal: Bool, animated: Bool)`	

- setup from Storyboard:
	- Place new  `UIViewControler` from your library inside the storyboard.
	- Set its class to `SideRevealViewController` from module `SideRevealKit`
	- make a manual storyboard segue "front reveal" (should be available in the popup menu) from  `SideRevealViewController` to the view controller you want to be loaded on the front, with identifier `"SideRevealKit-Front"` and class `FrontRevealSegue`
 	- make a manual storyboard segue "side reveal" (should be available in the popup menu) from  `SideRevealViewController` to the view controller you want to be loaded on the side, with identifier `"SideRevealKit-Side"` and class `SideRevealSegue`
	- When you want to reveal the side controller, you can call either: `SideRevealViewController.shared.toggleReveal()` or `SideRevealViewController.shared.revealSide(_ reveal: Bool, animated: Bool)`	 from your code.

*If you need more info, have a look at the example projects, there is one for storyboard setup and one for code setup.*

# Customisation

`SideRevealController`s have the following properties that you can use to tweak their appearance:

``` swift
// MARK: Public Settings

/// Property that controls how much the front(main) view controller is moved to the side on reveal.
///
/// On this property depends how wide your container for side controller's view will be.
@IBInspectable public var revealWidth: CGFloat = 250

/// Property that controls how much time is needed for the front(main)
/// view controller to move fully in order to reveal the side view controller.
@IBInspectable public var revealDuration: TimeInterval = 0.7

/// Property that controls the bounciness of the reveal action.
@IBInspectable public var revealDamping: CGFloat = 0.8

/// Used to set the color of the overlay that hides the front view on reveal.
@IBInspectable public var frontOverlayColor: UIColor = .clear

/// Used to set the alpha level of the overlay that hides the front view on reveal.
@IBInspectable public var frontOverlayAlpha: CGFloat = 0.7

/// This enables/disables the swipe to reveal gesture.
@IBInspectable  public  var revealOnSwipe = true

/// This defines the width of the stripe from which you can initiate the swipe to reveal gesture
/// as a percentage of the view controller's `view.bounds.width`.
@IBInspectable public var revealSwipeStartZone: CGFloat = 0.075
```

In addition to that, you can alter the `SideRevealControler.view.backgroundColor`, to match the design of your app. If You want to apply transformations, to either the front or the side view controller, you can access their container views from `SideRevealViewController.shared.frontContainer` and `SideRevealViewController.shared.sideContainer` and apply properties to them.

### Example: 
``` swift
// enables shadow on the front view controller, which drops on the side container when revealed.
SideRevealViewController.shared.frontContainer.layer.shadowOpacity = 1
```

You can also set `delegate` to `SideRevealController`s that will be notified when side reveal is happening.

``` swift
/// Set of all callbacks for reveal state switching of `SideRevealViewController`.
///
/// If you want to receive those, set yourself as delegate of the `SideRevealViewController`.
@objc public protocol SideRevealViewControllerDelegate: AnyObject {

/// Called when `SideRevealViewController` is about to switch its state.
///
/// - Parameters:
/// - sideRevealViewController: reference to the `SideRevealViewController`.
/// - reveal: true if side controller will be shown, false if it will be hidden.
/// - animated: true if reveal action will be animated, false if not.
@objc optional func sideRevealViewController(_ sideRevealViewController: SideRevealViewController, willReveal reveal: Bool, animated: Bool)
}
```

# Documentation

The project has webpage documentation inside `/Documentation` folder, generated with [jazzy](https://github.com/realm/jazzy). You can open it from XCode by building *Open Documentation* target. 

# Installation

### Carthage Installation

1. In your `Cartfile` add `github "stoqn4opm/SideRevealKit"`
2. Link the build framework with the target in your XCode project

For detailed instructions check the official Carthage guides [here](https://github.com/Carthage/Carthage)

### Manual Installation

1. Download the project and build the shared target called `SideRevealKit`
2. Add the product in the list of "embed frameworks" list inside your project's target or create a work space with SideRevealKit and your project and link directly the product of SideRevealKit's target to your target "embed frameworks" list

# Licence

The framework is licensed under MIT licence. For more information see file `LICENCE`
