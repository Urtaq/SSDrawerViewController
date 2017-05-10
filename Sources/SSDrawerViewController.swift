//
//  SSDrawerViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 5..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

let SSDrawerDefaultOpenStateRevealWidthHorizontal: CGFloat = UIScreen.main.bounds.size.width * (332.0 / 414.0)
let SSDrawerDefaultOpenStateRevealWidthVertical: CGFloat = 300.0
let SSPaneViewVelocityThreshold: CGFloat = 5.0
let SSPaneViewVelocityMultiplier: CGFloat = 5.0
let SSPaneViewScreenEdgeThreshold: CGFloat = 24.0; // After testing Apple's `UIScreenEdgePanGestureRecognizer` this seems to be the closest value to create an equivalent effect.
let SSPaneStatePositionValidityEpsilon: CGFloat = 2.0
let SSMainCoverViewMaxAlpha: CGFloat = 0.2

/**
 To respond to the updates to `paneState` for an instance of `MSDynamicsDrawerViewController`, configure a custom class to adopt the `MSDynamicsDrawerViewControllerDelegate` protocol and set it as the `delegate` object.
 */
protocol SSDrawerViewControllerDelegate: class {
    /**
     Informs the delegate that the drawer view controller will attempt to update to a pane state in the specified direction.

     It is important to note that the user is able to interrupt this change, and therefore is it not guaranteed that this update will occur. If desired, the user can be prevented from interrupting by passing `NO` for the `allowingUserInterruption` parameter in methods that update the `paneState`. For the aforementioned reasons, this method does not always pair with an invocation of `dynamicsDrawerViewController:didUpdateToPaneState:forDirection:`.

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param paneState The pane state that the view controller will attempt to update to.
     @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
     */
    func drawerViewController(_ drawerViewController: SSDrawerViewController, mayUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection)

    /**
     Informs the delegate that the drawer view controller did update to a pane state in the specified direction.

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param paneState The pane state that the view controller did update to.
     @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
     */
    func drawerViewController(_ drawerViewController: SSDrawerViewController, didUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection)

    /**
     Queries the delegate for whether the dynamics drawer view controller should begin a pane pan

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param panGestureRecognizer The internal pan gesture recognizer that is responsible for panning the pane. The behavior resulting from modifying attributes of this gesture recognizer is undefined and not recommended.

     @return Whether the drawer view controller should begin a pane pan
     */
    func drawerViewController(_ drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool
}

extension SSDrawerViewControllerDelegate {
    func drawerViewController(_ drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }
}

/**
 The drawer direction defines the direction that a `MSDynamicsDrawerViewController` instance's `paneView` can be opened in.

 The values can be masked in some (but not all) cases. See the parameters of individual methods to ensure compatibility with the `MSDynamicsDrawerDirection` that is being passed.
 */
struct SSDrawerDirection: OptionSet, Hashable, CustomStringConvertible {
    let rawValue: UInt

    /**
     Represents the state of no direction.
     */
    static let None = SSDrawerDirection(rawValue: UIRectEdge().rawValue)
    /**
     A drawer that is revealed from underneath the top edge of the pane.
     */
    static let Top = SSDrawerDirection(rawValue: UIRectEdge.top.rawValue)
    /**
     A drawer that is revealed from underneath the left edge of the pane.
     */
    static let Left = SSDrawerDirection(rawValue: UIRectEdge.left.rawValue)
    /**
     A drawer that is revealed from underneath the bottom edge of the pane.
     */
    static let Bottom = SSDrawerDirection(rawValue: UIRectEdge.bottom.rawValue)
    /**
     A drawer that is revealed from underneath the right edge of the pane.
     */
    static let Right = SSDrawerDirection(rawValue: UIRectEdge.right.rawValue)
    /**
     The drawers that are revealed from underneath both the left and right edges of the pane.
     */
    static let Horizontal = SSDrawerDirection(rawValue: UIRectEdge.left.rawValue | UIRectEdge.right.rawValue)
    /**
     The drawers that are revealed from underneath both the top and bottom edges of the pane.
     */
    static let Vertical = SSDrawerDirection(rawValue: UIRectEdge.top.rawValue | UIRectEdge.bottom.rawValue)
    /**
     The drawers that are revealed from underneath all edges of the pane.
     */
    static let All = SSDrawerDirection(rawValue: UIRectEdge.all.rawValue)

    static let AllTypes = [None, Top, Left, Bottom, Right, Horizontal, Vertical, All]

    internal var description: String {
        switch rawValue {
        case SSDrawerDirection.None.rawValue:
            return "SSDrawerDirection.None"
        case SSDrawerDirection.Top.rawValue:
            return "SSDrawerDirection.Top"
        case SSDrawerDirection.Left.rawValue:
            return "SSDrawerDirection.Left"
        case SSDrawerDirection.Bottom.rawValue:
            return "SSDrawerDirection.Bottom"
        case SSDrawerDirection.Right.rawValue:
            return "SSDrawerDirection.Right"
        case SSDrawerDirection.Horizontal.rawValue:
            return "SSDrawerDirection.Horizontal"
        case SSDrawerDirection.Vertical.rawValue:
            return "SSDrawerDirection.Vertical"
        case SSDrawerDirection.All.rawValue:
            return "SSDrawerDirection.All"
        default:
            return "SSDrawerDirection.None"
        }
    }

    internal var hashValue: Int {
        return Int(self.rawValue)
    }

    static func isValid(_ direction: SSDrawerDirection) -> Bool {
        switch direction {
        case SSDrawerDirection.None, SSDrawerDirection.Top, SSDrawerDirection.Left, SSDrawerDirection.Bottom, SSDrawerDirection.Right, SSDrawerDirection.Horizontal, SSDrawerDirection.Vertical, SSDrawerDirection.All:
            return true
        default:
            return false
        }
    }

    static func isCardinal(_ direction: SSDrawerDirection) -> Bool {
        switch direction {
        case SSDrawerDirection.Top, SSDrawerDirection.Left, SSDrawerDirection.Bottom, SSDrawerDirection.Right:
            return true
        default:
            return false
        }
    }

    static func isNonMasked(_ direction: SSDrawerDirection) -> Bool {
        switch direction {
        case None, Top, Left, Bottom, Right:
            return true
        default:
            return false
        }
    }

    static func drawerDirectionFromRawValue(_ rawValue: UInt) -> SSDrawerDirection {
        switch rawValue {
        case SSDrawerDirection.None.rawValue:
            return SSDrawerDirection.None
        case SSDrawerDirection.Top.rawValue:
            return SSDrawerDirection.Top
        case SSDrawerDirection.Left.rawValue:
            return SSDrawerDirection.Left
        case SSDrawerDirection.Bottom.rawValue:
            return SSDrawerDirection.Bottom
        case SSDrawerDirection.Right.rawValue:
            return SSDrawerDirection.Right
        case SSDrawerDirection.Horizontal.rawValue:
            return SSDrawerDirection.Horizontal
        case SSDrawerDirection.Vertical.rawValue:
            return SSDrawerDirection.Vertical
        case SSDrawerDirection.All.rawValue:
            return SSDrawerDirection.All
        default:
            return SSDrawerDirection.None
        }
    }

    static func drawerDirectionActionForMaskedValues(_ direction: SSDrawerDirection, action: SSDrawerActionBlock) -> Void {
        for drawerDirection in SSDrawerDirection.AllTypes {
            if (drawerDirection & direction) != SSDrawerDirection.None {
                action(drawerDirection)
            }
        }
    }

    subscript(indexes: Int...) -> [SSDrawerDirection] {
        var directions = [SSDrawerDirection]()

        for i in indexes {
            directions.append(SSDrawerDirection.AllTypes[i])
        }

        return directions
    }
}

func &(left: SSDrawerDirection, right: SSDrawerDirection) -> SSDrawerDirection {
    return SSDrawerDirection(rawValue: left.rawValue & right.rawValue)
}

func |(left: SSDrawerDirection, right: SSDrawerDirection) -> SSDrawerDirection {
    return SSDrawerDirection(rawValue: left.rawValue | right.rawValue)
}

func |=(left: inout SSDrawerDirection, right: SSDrawerDirection) -> Void {
    left = SSDrawerDirection(rawValue: left.rawValue | right.rawValue)
}

func ^=(left: inout SSDrawerDirection, right: SSDrawerDirection) -> Void {
    left = SSDrawerDirection(rawValue: left.rawValue ^ right.rawValue)
}

func ==(left: SSDrawerDirection, right: SSDrawerDirection) -> Bool {
    return left.rawValue == right.rawValue
}

func !=(left: SSDrawerDirection, right: SSDrawerDirection) -> Bool {
    return left.rawValue != right.rawValue
}

/**
 The possible drawer/pane visibility states of `MSDynamicsDrawerViewController`.
 */
enum SSDrawerMainState: Int, CustomStringConvertible {
    case none = 0
    /**
     The the drawer is entirely hidden by the pane.
     */
    case closed
    /**
     The drawer is revealed underneath the pane to the specified open width.
     */
    case open
    /**
     The drawer view is entirely visible, with the pane opened wide enough as to no longer be visible.
     */
    case openWide

    static let AllValues = [closed, open, openWide]

    var description: String {
        switch self {
        case .closed:
            return "SSDrawerMainState.Closed"
        case .open:
            return "SSDrawerMainState.Open"
        case .openWide:
            return "SSDrawerMainState.OpenWide"
        default:
            return "SSDrawerMainState.None"
        }
    }
}

func &(left: SSDrawerMainState, right: SSDrawerMainState) -> SSDrawerMainState {
    return SSDrawerMainState(rawValue: (left.rawValue & right.rawValue))!
}

func |(left: SSDrawerMainState, right: SSDrawerMainState) -> SSDrawerMainState {
    return SSDrawerMainState(rawValue: (left.rawValue | right.rawValue))!
}

//----------------
// @name Functions
//----------------

/**
 The action block used in @see MSDynamicsDrawerDirectionActionForMaskedValues.
 */
typealias SSDrawerActionBlock = (_ maskedValue: SSDrawerDirection) -> Void;

/**
 `SSDrawerViewController` is a container view controller that manages the presentation of a single "pane" view controller overlaid over one or two "drawer" view controllers. The drawer view controllers are hidden by default, but can be exposed by a user-initiated swipe in the direction that that drawer view controller is set in.
 */
class SSDrawerViewController: UIViewController, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {
    fileprivate let SSDrawerBoundaryIdentifier = "SSDrawerBoundaryIdentifier"

    //----------------------
    // @name Container Views
    //----------------------

    /**
     The pane view contains the pane view controller's view.

     The user can slide the `paneView` in any of the directions defined in `possibleDrawerDirection` to reveal the drawer view controller underneath. The frame of the `paneView` is frequently updated by internal dynamics and user gestures.
     */
    var mainView: UIView
    var mainCoverView: UIView
    /**
     The drawer view contains the currently visible drawer view controller's view.

     The `drawerView` is always presented underneath the `paneView`. The frame of the `drawerView` never moves, and it is not affected by dynamics.
     */
    var drawerView: UIView

    //------------------------------------
    // @name Accessing the Delegate Object
    //------------------------------------

    /**
     The delegate you want to receive dynamics drawer view controller messages.

     The dynamics drawer view controller informs its delegate of changes to the state of the drawer view controller. For more information about the methods you can implement in your delegate, `MSDynamicsDrawerViewControllerDelegate`.
     */
    weak var delegate: SSDrawerViewControllerDelegate?

    //------------------------------------------
    // @name Managing the Child View Controllers
    //------------------------------------------

    /**
     The pane view controller is the primary view controller, displayed centered and covering the drawer view controllers.

     @see setMainViewController:animated:completion:
     @see paneState
     */
    var _mainViewController: UIViewController? = nil
    var mainViewController: UIViewController? {
        get {
            return self._mainViewController
        }
        set {
            self.replaceViewController(self._mainViewController, withViewController: newValue, inContainerView: self.mainView) { [weak self] in
                guard let wself = self else { return }

                wself._mainViewController = newValue
                wself.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    //----------------------------------
    // @name Accessing & Modifying State
    //----------------------------------

    /**
     The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.

     The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal width for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is more than one drawer view controller set, use `setPaneState:inDirection:` instead and specify a direction.

     @see setPaneState:inDirection:
     @see setPaneState:animated:allowUserInterruption:completion:
     @see setPaneState:inDirection:animated:allowUserInterruption:completion:
     */
    var _mainState: SSDrawerMainState
    var mainState: SSDrawerMainState {
        get {
            return self._mainState
        }
        set {
            self.setMainState(newValue, animated: false, allowUserInterruption: false, completion: nil)
        }
    }

    /**
     The directions that the `paneView` can be opened in.

     Corresponds to the directions that there are drawer view controllers set for. If more than one drawer view controller is set, this will be a bitmask of the directions that the drawer view controllers are set in.
     */
    var possibleDrawerDirection: SSDrawerDirection
    var mainViewSlideOffAnimationEnabled: Bool
    var shouldAlignStatusBarToPaneView: Bool

    var dynamicAnimator: UIDynamicAnimator?
    var mainPushBehavior: UIPushBehavior?
    var mainElasticityBehavior: UIDynamicItemBehavior?
    var mainGravityBehavior: UIGravityBehavior?
    var mainBoundaryCollisionBehavior: UICollisionBehavior?
    var dynamicAnimatorCompletion: (()->Void)?

    // State
    var _currentDrawerDirection: SSDrawerDirection
    var currentDrawerDirection: SSDrawerDirection {
        get {
            return self._currentDrawerDirection
        }
        set {
            assert(SSDrawerDirection.isNonMasked(newValue), "Only accepts non-masked directions as current reveal direction")
            assert(!((newValue == .None) && (self.mainState != .closed)), "Can't set direction to none while we have a non-closed pane state")

            if !(self._currentDrawerDirection == newValue) {

                // Inform stylers about the transition between directions when directly transitioning
                if (self._currentDrawerDirection != .None) {
                    let allStylers: NSMutableSet = NSMutableSet();
                    for stylers in self.stylers.values {
                        allStylers.union(with: stylers)//union(stylers as Set)
                    }
                    for styler in allStylers {
                        let drawerStyler: SSDrawerStyler = styler as! SSDrawerStyler
                        drawerStyler.styleDrawerViewController(self, didUpdatePaneClosedFraction: 1.0, forDirection: .None)
                    }
                }

                self._currentDrawerDirection = newValue;

                self.drawerViewController = self.drawerViewControllers[newValue];

                // Disable pane view interaction when not closed
                self.setPaneViewControllerViewUserInteractionEnabled(newValue == .None)

                self.updateStylers()
            }
        }
    }

    var _drawerViewController: UIViewController?
    var drawerViewController: UIViewController? {
        get {
            return self._drawerViewController
        }
        set {
            self.replaceViewController(self._drawerViewController, withViewController: newValue, inContainerView: self.drawerView) { [weak self] in
                guard let wself = self else { return }

                wself._drawerViewController = newValue
            }
        }
    }

    // Internal Properties
    var drawerViewControllers: [SSDrawerDirection: UIViewController]
    var revealWidth: [SSDrawerDirection: CGFloat] = [SSDrawerDirection: CGFloat]()
    var openStateRevealWidth: CGFloat {
        return self.revealWidthForDirection(self.currentDrawerDirection)
    }
    var paneDragRevealEnabled: [SSDrawerDirection: Bool] = [SSDrawerDirection: Bool]()
    var paneTapToCloseEnabled: [SSDrawerDirection: Bool] = [SSDrawerDirection: Bool]()
    var stylers: [SSDrawerDirection: NSSet] = [SSDrawerDirection: NSSet]()
    var paneStateOpenWideEdgeOffset: CGFloat
    var potentialPaneState: SSDrawerMainState
    var animatingRotation: Bool

    // Gestures
    var touchForwardingClasses: NSMutableSet = [UISlider.self, UISwitch.self]
    var panePanGestureRecognizer: UIPanGestureRecognizer?
    var paneTapGestureRecognizer: UITapGestureRecognizer?

    // -------------------------------------
    //  @name Configuring Dynamics Behaviors
    // -------------------------------------

    /**
     The magnitude of the gravity vector that affects the pane view.

     Default value of `2.0`. A magnitude value of `1.0` represents an acceleration of 1000 points / second².
     */
    var gravityMagnitude: CGFloat

    /**
     The elasticity applied to the pane view.

     Default value of `0.0`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.
     */
    var elasticity: CGFloat

    /**
     The amount of elasticity applied to the pane view when it is bounced open.

     Applies when the pane is bounced open. Default value of `0.5`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.

     @see bouncePaneOpen
     @see bouncePaneOpenInDirection:
     */
    var bounceElasticity: CGFloat

    /**
     The magnitude of the push vector that is applied to the pane view when bouncePaneOpen is called.

     Applies when the pane is bounced open. Default of 60.0. A magnitude value of 1.0 represents an acceleration of 1000 points / second².

     @see bouncePaneOpen
     @see bouncePaneOpenInDirection:
     */
    var bounceMagnitude: CGFloat

    // --------------------------
    // @name Configuring Gestures
    // --------------------------

    /**
     Whether the only pans that can open the drawer should be those that originate from the screen's edges.

     If set to `YES`, pans that originate elsewhere are ignored and have no effect on the drawer. This property is designed to mimic the behavior of the `UIScreenEdgePanGestureRecognizer` as applied to the `MSDynamicsDrawerViewController` interaction paradigm. Setting this property to `YES` yields a similar behavior to that of screen edge pans within a `UINavigationController` in iOS7+. Defaults to `NO`.

     @see screenEdgePanCancelsConflictingGestures
     */
    var paneDragRequiresScreenEdgePan: Bool = false

    /**
     Whether gestures that start at the edge of the screen should be cancelled under the assumption that the user is dragging the pane view to reveal a drawer underneath.

     This behavior only applies to edges that have a corresponding drawer view controller set in the same direction as the edge that the gesture originated in. The primary use of this property is the case of having a `UIScrollView` within the view of the active pane view controller. When the drawers are closed and the user starts a pan-like gesture at the edge of the screen, all other conflicting gesture recognizers will be required to fail, yielding to the internal `UIPanGestureRecognizer` in the `MSDynamicsDrawerViewController` instance. Effectually, this property makes it easier for the user to open the drawers. Defaults to `YES`.

     @see paneDragRequiresScreenEdgePan
     */
    var screenEdgePanCancelsConflictingGestures: Bool = true

    required init?(coder aDecoder: NSCoder) {

        self._mainState = .closed
        self.mainViewSlideOffAnimationEnabled = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
        self.shouldAlignStatusBarToPaneView = true
        self._currentDrawerDirection = SSDrawerDirection.None
        self.potentialPaneState = .none
        self.animatingRotation = false
        self.possibleDrawerDirection = SSDrawerDirection.None

        self.mainView = UIView()
        self.mainCoverView = UIView()
        self.drawerView = UIView()

        self.gravityMagnitude = 2.0
        self.elasticity = 0.0
        self.bounceElasticity = 0.5
        self.bounceMagnitude = 60.0
        self.paneStateOpenWideEdgeOffset = 20.0

        self.drawerViewControllers = [SSDrawerDirection: UIViewController]()

        super.init(coder: aDecoder)

        self.mainView.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

        self.initializeGesture()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        self._mainState = .closed
        self.mainViewSlideOffAnimationEnabled = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
        self.shouldAlignStatusBarToPaneView = true
        self._currentDrawerDirection = SSDrawerDirection.None
        self.potentialPaneState = .none
        self.animatingRotation = false
        self.possibleDrawerDirection = SSDrawerDirection.None

        self.mainView = UIView()
        self.mainView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.mainCoverView = UIView()
        self.mainCoverView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.drawerView = UIView()
        self.drawerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        self.gravityMagnitude = 2.0
        self.elasticity = 0.0
        self.bounceElasticity = 0.5
        self.bounceMagnitude = 60.0
        self.paneStateOpenWideEdgeOffset = 20.0

        self.drawerViewControllers = [SSDrawerDirection: UIViewController]()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.mainView.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

        self.initializeGesture()
    }

    deinit {
        self.mainView.removeObserver(self, forKeyPath: "frame")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.drawerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.drawerView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.drawerView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.drawerView]))

        self.mainView.frame = self.view.bounds
        self.view.addSubview(self.mainView)

        self.mainCoverView.frame = self.view.bounds
        self.mainCoverView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        self.mainCoverView.alpha = 0.0

        self.dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        self.dynamicAnimator?.delegate = self

        self.mainBoundaryCollisionBehavior = UICollisionBehavior(items: [self.mainView])
        self.mainGravityBehavior = UIGravityBehavior(items: [self.mainView])
        self.mainPushBehavior = UIPushBehavior(items: [self.mainView], mode: .instantaneous)
        self.mainElasticityBehavior = UIDynamicItemBehavior(items: [self.mainView])

        self.mainGravityBehavior?.action = { [weak self] in
            guard let wself = self else { return }

            wself.didUpdateDynamicAnimatorAction()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] (transitionCoordinatorContext) in
            guard let wself = self else { return }

            wself.animatingRotation = true
            }) { [weak self] (transitionCoordinatorContext) in
                guard let wself = self else { return }

                wself.animatingRotation = false
                wself.updateStylers()
        }

        super.viewWillTransition(to: size, with: coordinator)
    }

    override var shouldAutorotate : Bool {
        return (!self.dynamicAnimator!.isRunning && (self.panePanGestureRecognizer!.state == UIGestureRecognizerState.possible))
    }

    func initializeGesture() -> Void {

        self.panePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panePanned))
        self.panePanGestureRecognizer?.minimumNumberOfTouches = 1;
        self.panePanGestureRecognizer?.maximumNumberOfTouches = 1;
        self.panePanGestureRecognizer?.delegate = self;
        self.mainView.addGestureRecognizer(self.panePanGestureRecognizer!)

        self.paneTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(paneTapped))
        self.paneTapGestureRecognizer?.numberOfTouchesRequired = 1;
        self.paneTapGestureRecognizer?.numberOfTapsRequired = 1;
        self.paneTapGestureRecognizer?.delegate = self;
        self.mainView.addGestureRecognizer(self.paneTapGestureRecognizer!)
    }


// MARK: - Main(Pane) View Controller
    /**
     Sets the `paneViewController` with an animated transition.

     If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneViewController` setter.

     @param paneViewController The `paneViewController` to be added.
     @param animated Whether adding the pane should be animated.
     @param completion An optional completion block called upon the completion of the `paneViewController` being set.

     @see paneViewController
     @see paneViewSlideOffAnimationEnabled
     */
    func setMainViewController(_ mainViewController: UIViewController, animated: Bool, completion: (()-> Void)?) -> Void {
        if !animated {
            self.mainViewController = mainViewController
            guard let _ = completion?() else {
                return
            }

            return
        }

        if self.mainViewController != mainViewController {
            self.mainViewController?.willMove(toParentViewController: nil)
            self.mainViewController?.beginAppearanceTransition(true, animated: animated)

            let transitionToNewMainViewController: () -> Void = {
                mainViewController.willMove(toParentViewController: self)
                self.mainViewController?.view.removeFromSuperview()
                self.mainViewController?.removeFromParentViewController()
                self.mainViewController?.didMove(toParentViewController: nil)
                self.mainViewController?.endAppearanceTransition()

                self.addChildViewController(mainViewController)
                mainViewController.beginAppearanceTransition(true, animated: animated)
                self.mainView.addSubview(mainViewController.view)
                mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.mainView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": mainViewController.view]))
                self.mainView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": mainViewController.view]))

                self.mainViewController = mainViewController
                self.mainView.setNeedsDisplay()

                CATransaction.flush()

                self.setNeedsStatusBarAppearanceUpdate()

                self.mainViewController = mainViewController
//                dispatch_async(dispatch_get_main_queue(), { [weak self] in
//                    guard let wself = self else { return }
//
//                    wself.mainViewController = mainViewController
//                })
            }

            if self.mainViewSlideOffAnimationEnabled {
                self.setMainState(.openWide, animated: animated, allowUserInterruption: false, completion: transitionToNewMainViewController)
            } else {
                transitionToNewMainViewController()
            }
        }
        // If trying to set to the currently visible pane view controller, just close
        else {
            self.setMainState(.closed, animated: animated, allowUserInterruption: true, completion: {
                guard let _ = completion else {
                    return
                }
            })
        }
    }

// MARK: - Bouncing

    func drawerViewControllerForDirection(_ direction: SSDrawerDirection) -> UIViewController? {
        assert(SSDrawerDirection.isCardinal(direction), "Only cardinal reveal directions are accepted")
        return self.drawerViewControllers[direction]
    }

// MARK: - Generic View Controller Containment

    func replaceViewController(_ existingViewController: UIViewController?, withViewController newViewController: UIViewController?, inContainerView containerView: UIView, completion: (()-> Void)?) -> Void {
        // Add initial view controller
        if (existingViewController == nil) && (newViewController != nil) {
            if let newVC = newViewController {
                newVC.willMove(toParentViewController: self)
                newVC.beginAppearanceTransition(true, animated: false)

                self.addChildViewController(newVC)
                containerView.addSubview(newVC.view)
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                var metrics: [String: CGFloat] = ["left": 0, "right": 0]
                switch self.currentDrawerDirection {
                case SSDrawerDirection.Left:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                case SSDrawerDirection.Right:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                case SSDrawerDirection.Horizontal:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                default:
                    break
                }
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-left-[view]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["view": newVC.view]))
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": newVC.view]))

                newVC.didMove(toParentViewController: self)
                newVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
        // Remove existing view controller
        else if (existingViewController != nil) && (newViewController == nil) {
            if let existingVC = existingViewController {
                existingVC.willMove(toParentViewController: nil)
                existingVC.beginAppearanceTransition(false, animated: false)
                existingVC.view.removeFromSuperview()
                existingVC.removeFromParentViewController()
                existingVC.didMove(toParentViewController: nil)
                existingVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
        // Replace existing view controller with new view controller
        else if (existingViewController !== newViewController) && (newViewController != nil) {
            if let newVC = newViewController, let existingVC = existingViewController {
                newVC.willMove(toParentViewController: self)
                existingVC.willMove(toParentViewController: nil)
                existingVC.beginAppearanceTransition(false, animated: false)
                existingVC.view.removeFromSuperview()
                existingVC.removeFromParentViewController()
                existingVC.didMove(toParentViewController: nil)
                existingVC.endAppearanceTransition()
                newVC.beginAppearanceTransition(true, animated: false)

                self.addChildViewController(newVC)
                containerView.addSubview(newVC.view)
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                var metrics: [String: CGFloat] = ["left": 0, "right": 0]
                switch self.currentDrawerDirection {
                case SSDrawerDirection.Left:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                case SSDrawerDirection.Right:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                case SSDrawerDirection.Horizontal:
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                    metrics.updateValue(UIScreen.main.bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                default:
                    break
                }
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-left-[view]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["view": newVC.view]))
                containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": newVC.view]))

                newVC.didMove(toParentViewController: self)
                newVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
    }

// MARK: - DrawerViewController

    func setDrawerViewController(_ drawerViewController: UIViewController?, forDirection direction: SSDrawerDirection) -> Void {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts cardinal reveal directions")
        for currentDrawerViewController in self.drawerViewControllers.values {
            assert(currentDrawerViewController != drawerViewController, "Unable to add a drawer view controller when it's previously been added")
        }
        if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            assert(!(self.drawerViewControllers[SSDrawerDirection.Top] != nil || self.drawerViewControllers[SSDrawerDirection.Bottom] != nil), "Unable to simultaneously have top/bottom drawer view controllers while setting left/right drawer view controllers")
        } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            assert(!(self.drawerViewControllers[SSDrawerDirection.Left] != nil || self.drawerViewControllers[SSDrawerDirection.Right] != nil), "Unable to simultaneously have left/right drawer view controllers while setting top/bottom drawer view controllers")
        }

        let existingDrawerViewController = self.drawerViewControllers[direction]
        // New drawer view controller
        if drawerViewController != nil && existingDrawerViewController == nil {
            self.possibleDrawerDirection |= direction
            self.drawerViewControllers[direction] = drawerViewController
        }
        // Removing existing drawer view controller
        else if drawerViewController == nil && existingDrawerViewController != nil {
            self.possibleDrawerDirection ^= direction
            self.drawerViewControllers.removeValue(forKey: direction)
        }
        // Replace existing drawer view controller
        else if drawerViewController != nil && existingDrawerViewController != nil {
            self.drawerViewControllers[direction] = drawerViewController
        }
    }

// MARK:- Dynamics

    func didUpdateDynamicAnimatorAction() -> Void {
        self.paneViewDidUpdateFrame()
    }

    func addDynamicsBehaviorsToCreatePaneState(_ paneState: SSDrawerMainState) -> Void {
        self.addDynamicsBehaviorsToCreatePaneState(paneState, pushMagnitude: 0, pushAngle: 0, pushElasticity: self.elasticity)
    }

    func addDynamicsBehaviorsToCreatePaneState(_ paneState: SSDrawerMainState, pushMagnitude: CGFloat, pushAngle: CGFloat, pushElasticity: CGFloat) -> Void {
        if self.currentDrawerDirection == SSDrawerDirection.None {
            return
        }

        self.setPaneViewControllerViewUserInteractionEnabled(paneState == SSDrawerMainState.closed)

        self.mainBoundaryCollisionBehavior?.removeAllBoundaries()
        self.mainBoundaryCollisionBehavior?.addBoundary(withIdentifier: SSDrawerBoundaryIdentifier as NSCopying, for: self.boundaryPathForState(paneState, direction: self.currentDrawerDirection))
        self.dynamicAnimator?.addBehavior(self.mainBoundaryCollisionBehavior!)

        self.mainGravityBehavior?.magnitude = self.gravityMagnitude
        self.mainGravityBehavior?.angle = self.gravityAngleForState(paneState, direction: self.currentDrawerDirection)
        self.dynamicAnimator?.addBehavior(self.mainGravityBehavior!)

        if pushElasticity != 0.0 {
            self.mainElasticityBehavior?.elasticity = elasticity
            self.dynamicAnimator?.addBehavior(self.mainElasticityBehavior!)
        }

        if pushMagnitude != 0.0 {
            self.mainPushBehavior?.angle = CGFloat(pushAngle)
            self.mainPushBehavior?.magnitude = CGFloat(pushMagnitude)
            self.mainPushBehavior?.active = true
            self.dynamicAnimator?.addBehavior(self.mainPushBehavior!)
        }

        self.potentialPaneState = paneState

        guard let _ = self.delegate?.drawerViewController(self, mayUpdateToPaneState: paneState, forDirection: self.currentDrawerDirection) else {
            print("\(#line):This drawerViewController delegate doesn't have the function 'drawerViewController(_:mayUpdateToPaneState:forDirection:)'")
            return
        }
    }

    func boundaryPathForState(_ state: SSDrawerMainState, direction: SSDrawerDirection) -> UIBezierPath {
        assert(SSDrawerDirection.isCardinal(direction), "Boundary is undefined for a non-cardinal reveal direction")

        var boundary: CGRect = CGRect.zero
        boundary.origin = CGPoint(x: -1.0, y: -1.0)
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            boundary.size.height = self.mainView.frame.height + 1.0
            switch state {
            case SSDrawerMainState.closed, .openWide:
                boundary.size.width = self.mainView.frame.width * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            case .open:
                boundary.size.width = self.mainView.frame.width + self.openStateRevealWidth + 2.0
            default:
                break
            }
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            boundary.size.width = self.mainView.frame.width + 1.0
            switch state {
            case SSDrawerMainState.closed:
                boundary.size.height = self.mainView.frame.height * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            case SSDrawerMainState.open:
                boundary.size.height = self.mainView.frame.height + self.openStateRevealWidth + 2.0
            case SSDrawerMainState.openWide:
                boundary.size.height = self.mainView.frame.height * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            default:
                break
            }
        }

        switch direction {
        case SSDrawerDirection.Right:
            boundary.origin.x = self.mainView.frame.width + 1.0 - boundary.size.width
        case SSDrawerDirection.Bottom:
            boundary.origin.y = self.mainView.frame.height + 1.0 - boundary.size.height
        case SSDrawerDirection.None:
            boundary = CGRect.zero
        default:
            break
        }

        return UIBezierPath(rect: boundary)
    }

    func gravityAngleForState(_ state: SSDrawerMainState, direction: SSDrawerDirection) -> CGFloat {
        assert(SSDrawerDirection.isCardinal(direction), "Indeterminate gravity angle for non-cardinal reveal direction")

        switch direction {
        case SSDrawerDirection.Top:
            return CGFloat((state != SSDrawerMainState.closed) ? .pi / 2 : (3.0 * .pi / 2))
        case SSDrawerDirection.Left:
            return CGFloat((state != SSDrawerMainState.closed) ? 0.0 : .pi)
        case SSDrawerDirection.Bottom:
            return CGFloat((state != SSDrawerMainState.closed) ? (3.0 * .pi / 2) : .pi / 2)
        case SSDrawerDirection.Right:
            return CGFloat((state != SSDrawerMainState.closed) ? .pi : 0.0)
        default:
            return 0.0
        }
    }

// MARK: - Closed Fraction
    func paneViewClosedFraction() -> CGFloat {
        var fraction: CGFloat = 0.0

        switch self.currentDrawerDirection {
        case SSDrawerDirection.Top:
            fraction = (self.openStateRevealWidth - self.mainView.frame.origin.y) / self.openStateRevealWidth
        case SSDrawerDirection.Left:
            fraction = (self.openStateRevealWidth - self.mainView.frame.origin.x) / self.openStateRevealWidth
        case SSDrawerDirection.Bottom:
            fraction = (1 - fabs(self.mainView.frame.origin.y)) / self.openStateRevealWidth
        case SSDrawerDirection.Right:
            fraction = (1 - fabs(self.mainView.frame.origin.x)) / self.openStateRevealWidth
        case SSDrawerDirection.None:
            fraction = 1
        default:
            break
        }

        fraction = (fraction < 0) ? 0 : fraction
        fraction = (fraction > 1) ? 1 : fraction

        return fraction
    }

// MARK: - Stylers

    func addStyler(_ styler: SSDrawerStyler, forDirection direction: SSDrawerDirection) -> Void {
        SSDrawerDirection.drawerDirectionActionForMaskedValues(direction) { [weak self] (maskedValue) in
            guard let wself = self else { return }
            
            if wself.stylers[maskedValue] == nil {
                wself.stylers[maskedValue] = NSMutableSet()
            }

            if let stylersSet: NSMutableSet = wself.stylers[maskedValue] as? NSMutableSet {
                stylersSet.add(styler)

                var existsInCurrentStylers: Bool = false
                for currentStylersSet: NSSet in wself.stylers.values {
                    existsInCurrentStylers = currentStylersSet.contains(styler)
                }

                if existsInCurrentStylers {
                    styler.stylerWasAddedToDrawerViewController(wself, forDirection: direction)
                }
            }
        }
    }

    func removeStyler(_ styler: SSDrawerStyler, forDirection: SSDrawerDirection) -> Void {
        SSDrawerDirection.drawerDirectionActionForMaskedValues(forDirection) { [weak self] (maskedValue) in
            guard let wself = self else { return }

            if let stylersSet: NSMutableSet = wself.stylers[maskedValue] as? NSMutableSet {
                stylersSet.remove(styler)

                var containedCount: Int = 0
                for currentStylersSet: NSSet in wself.stylers.values {
                    if currentStylersSet.contains(styler) {
                        containedCount += 1
                    }
                }

                if containedCount == 0 {
                    styler.stylerWasRemovedFromDrawerViewController(wself, forDirection: forDirection)
                }
            }
        }
    }

    func addStylerFromArray(_ stylers: [SSDrawerStyler], forDirection: SSDrawerDirection) -> Void {
        for styler in stylers {
            self.addStyler(styler, forDirection: forDirection)
        }
    }

    func updateStylers() -> Void {
        if self.animatingRotation {
            return
        }

        let activeStylers: NSMutableSet = NSMutableSet()
        if SSDrawerDirection.isCardinal(self.currentDrawerDirection) {
            activeStylers.union(with: self.stylers[self.currentDrawerDirection]!)// as! Set)
        } else {
            for stylers in self.stylers.values {
                activeStylers.union(with: stylers)//.union(stylers as Set)
            }
        }

        for styler in activeStylers {
            let drawerStyler = styler as! SSDrawerStyler
            drawerStyler.styleDrawerViewController(self, didUpdatePaneClosedFraction: self.paneViewClosedFraction(), forDirection: self.currentDrawerDirection)
        }
    }

// MARK:- Pane State

    func paneViewDidUpdateFrame() -> Void {
        if self.shouldAlignStatusBarToPaneView {

            let chars: [CUnsignedChar] = [0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72]
            let data: Data = Data(bytes: UnsafePointer<UInt8>(chars), count: 9)
            let key: String = String(data: data, encoding: String.Encoding.ascii)!

            let application: UIApplication = UIApplication.shared
            var statusBar: UIView?;
            if application.responds(to: NSSelectorFromString(key)) {
                statusBar = application.value(forKey: key) as? UIView
            }
            statusBar!.transform = CGAffineTransform(translationX: self.mainView.frame.origin.x, y: self.mainView.frame.origin.y);
        }

        let openWidePoint: CGPoint = self.paneViewOriginForPaneState(.openWide)
        let paneFrame: CGRect = self.mainView.frame
        var openWideLocation: CGFloat = 0
        var paneLocation: CGFloat = 0

        if (self.currentDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            openWideLocation = openWidePoint.x
            paneLocation = paneFrame.origin.x
        } else if (self.currentDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            openWideLocation = openWidePoint.y
            paneLocation = paneFrame.origin.y
        }

        var reachedOpenWideState: Bool = false
        if (self.currentDrawerDirection & [SSDrawerDirection.Left, SSDrawerDirection.Top]) != SSDrawerDirection.None {
            if paneLocation != 0 && (paneLocation >= openWideLocation) {
                reachedOpenWideState = true
            }
        } else if (self.currentDrawerDirection & [SSDrawerDirection.Right, SSDrawerDirection.Bottom]) != SSDrawerDirection.None {
            if paneLocation != 0 && (paneLocation <= openWideLocation) {
                reachedOpenWideState = true
            }
        }

        if reachedOpenWideState && (self.potentialPaneState == .openWide) {
            self.dynamicAnimator?.removeAllBehaviors()
        }

        self.updateStylers()
    }

    func paneViewOriginForPaneState(_ paneState: SSDrawerMainState) -> CGPoint {
        var paneViewOrigin: CGPoint = CGPoint.zero
        switch paneState {
        case .open:
            switch self.currentDrawerDirection {
            case SSDrawerDirection.Top:
                paneViewOrigin.y = CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Left:
                paneViewOrigin.x = CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Bottom:
                paneViewOrigin.y = -CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Right:
                paneViewOrigin.x = -CGFloat(self.openStateRevealWidth)
            default:
                break
            }
        case .openWide:
            switch self.currentDrawerDirection {
            case SSDrawerDirection.Left:
                paneViewOrigin.x = (self.mainView.frame.width + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Top:
                paneViewOrigin.y = (self.mainView.frame.width + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Bottom:
                paneViewOrigin.y = (self.mainView.frame.width + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Right:
                paneViewOrigin.x = -(self.mainView.frame.width + self.paneStateOpenWideEdgeOffset)
            default:
                break
            }
        default:
            break
        }

        return paneViewOrigin
    }

    func setMainState(_ paneState: SSDrawerMainState, inDirection direction: SSDrawerDirection) -> Void {
        self.setMainState(paneState, inDirection: direction, animated: false, allowUserInterruption: false, completion: nil)
    }

    func setMainState(_ paneState: SSDrawerMainState, animated: Bool, allowUserInterruption: Bool, completion: (()-> Void)?) -> Void {
        // If the drawer is getting opened and there's more than one possible direction enforce that the directional eqivalent is used
        var direction: SSDrawerDirection?
        if (paneState != .closed) && (self.currentDrawerDirection == .None) {
            assert(SSDrawerDirection.isCardinal(self.possibleDrawerDirection), "Unable to set the pane to an open state with multiple possible drawer directions, as the drawer direction to open in is indeterminate. Use `setPaneState:inDirection:animated:allowUserInterruption:completion:` instead.")
            direction = self.possibleDrawerDirection
        } else {
            direction = self.currentDrawerDirection
        }

        self.setMainState(paneState, inDirection: direction!, animated: animated, allowUserInterruption: allowUserInterruption, completion: completion)
    }

    func setMainState(_ paneState: SSDrawerMainState, inDirection direction: SSDrawerDirection, animated: Bool, allowUserInterruption: Bool, completion: (()->Void)?) -> Void {
        assert((self.possibleDrawerDirection & direction) == direction, "Unable to bounce open with impossible or multiple directions")

        // If the pane is already positioned in the desired pane state and direction, don't continue
        var currentPaneState: SSDrawerMainState = .closed
        if self.paneViewIsPositionedInValidState(&currentPaneState) && (currentPaneState == paneState) {
            // If already closed, *in any direction*, don't continue
            if currentPaneState == .closed {
                guard let _ = completion else {
                    return
                }
                return
            }
            // If opened, *in the correct direction*, don't continue
            else if direction == self.currentDrawerDirection {
                guard let _ = completion else {
                    return
                }
                return
            }
        }

        // If opening in a specified direction, set the drawer to that direction
        if paneState != .closed {
            self.currentDrawerDirection = direction
        }

        if animated {
            self.addDynamicsBehaviorsToCreatePaneState(paneState)
            if !allowUserInterruption {
                self.setViewUserInteractionEnabled(false)
            }
            self.dynamicAnimatorCompletion = { [weak self] in
                if !allowUserInterruption {
                    self?.setViewUserInteractionEnabled(true)
                    guard let _ = completion else {
                        return
                    }
                }
            }
        } else {
            self._setMainState(paneState)
            guard let _ = completion else {
                return
            }
        }
    }

    fileprivate func _setMainState(_ paneState: SSDrawerMainState) -> Void {
        let previousDirection: SSDrawerDirection = self.currentDrawerDirection

        // When we've actually upated to a pane state, invalidate the `potentialPaneState`
        self.potentialPaneState = .none

        if self.mainState != paneState {
            self.willChangeValue(forKey: "mainState")
            self._mainState = paneState
            if (self.mainState & (SSDrawerMainState.open | SSDrawerMainState.openWide)) != .none {
                guard let _ = self.delegate?.drawerViewController(self, didUpdateToPaneState: paneState, forDirection: self.currentDrawerDirection) else {
                    return
                }
            } else {
                guard let _ = self.delegate?.drawerViewController(self, didUpdateToPaneState: paneState, forDirection: previousDirection) else {
                    return
                }
            }
            self.didChangeValue(forKey: "mainState")
        }

        // Update pane frame regardless of if it's changed
        self.mainView.frame.origin = self.paneViewOriginForPaneState(paneState)

        // Update `currentDirection` to `MSDynamicsDrawerDirectionNone` if the `paneState` is `MSDynamicsDrawerPaneStateClosed`
        if paneState == SSDrawerMainState.closed {
            self.currentDrawerDirection = SSDrawerDirection.None
        }
    }

    func paneViewIsPositionedInValidState(_ paneState: inout SSDrawerMainState) -> Bool {
        var validState = false
        for currentPaneState: SSDrawerMainState in SSDrawerMainState.AllValues {
            let paneStatePaneViewOrigin: CGPoint = self.paneViewOriginForPaneState(currentPaneState)
            let currentPaneViewOrigin: CGPoint = CGPoint(x: round(self.mainView.frame.origin.x), y: round(self.mainView.frame.origin.y))

            if (fabs(paneStatePaneViewOrigin.x - currentPaneViewOrigin.x) < SSPaneStatePositionValidityEpsilon)
                && (fabs(paneStatePaneViewOrigin.y - currentPaneViewOrigin.y) < SSPaneStatePositionValidityEpsilon) {
                validState = true
                paneState = currentPaneState
                break
            }
        }

        return validState
    }

    func nearestPaneState() -> SSDrawerMainState {
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var minPaneState: SSDrawerMainState = .none
        for currentPaneState: SSDrawerMainState in SSDrawerMainState.AllValues {
            let paneStatePaneViewOrigin: CGPoint = self.paneViewOriginForPaneState(currentPaneState)
            let currentPaneViewOrigin: CGPoint = CGPoint(x: round(self.mainView.frame.origin.x), y: round(self.mainView.frame.origin.y))
            let distance: CGFloat = sqrt(pow(paneStatePaneViewOrigin.x - currentPaneViewOrigin.x, 2) + pow(paneStatePaneViewOrigin.y - currentPaneViewOrigin.y, 2))
            if distance < minDistance {
                minDistance = distance
                minPaneState = currentPaneState
            }
        }
        return minPaneState
    }

// MARK:- Possible Reveal Direction
//    func setPossibleDrawerDirection(possibleDrawerDirection: SSDrawerDirection) -> Void {
//        assert(SSDrawerDirection().SSDrawerDirectionIsValid(possibleDrawerDirection), "Only accepts valid reveal directions as possible reveal direction")
//        self.possibleDrawerDirection = possibleDrawerDirection
//    }

// MARK: Reveal Width
    func revealWidthForDirection(_ direction: SSDrawerDirection) -> CGFloat {
        assert(SSDrawerDirection.isValid(direction), "Only accepts cardinal directions when querying for reveal width")
        var revealWidth: CGFloat = 0

        if let width = self.revealWidth[direction] {
            revealWidth = width
        }

        if revealWidth == 0 {
            if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                revealWidth = SSDrawerDefaultOpenStateRevealWidthHorizontal
            } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                revealWidth = SSDrawerDefaultOpenStateRevealWidthVertical
            } else {
                revealWidth = 0.0
            }
        }

        return revealWidth
    }

    func setRevealWidth(_ revealWidth: CGFloat, forDirection direction:SSDrawerDirection) -> Void {
        assert(self.mainState == SSDrawerMainState.closed, "Only able to update the reveal width while the pane view is closed")
        SSDrawerDirection.drawerDirectionActionForMaskedValues(direction) { [weak self] (maskedValue) in
            guard let wself = self else { return }

            wself.revealWidth[maskedValue] = revealWidth
        }
    }

    func currentRevealWidth() -> CGFloat {
        switch self.currentDrawerDirection {
        case SSDrawerDirection.Left, SSDrawerDirection.Right:
            return fabs(self.mainView.frame.origin.x)
        case SSDrawerDirection.Top, SSDrawerDirection.Bottom:
            return fabs(self.mainView.frame.origin.y)
        default:
            return 0.0
        }
    }

// MARK:- User Interaction
    func setViewUserInteractionEnabled(_ enabled: Bool) -> Void {
        var disableCount: Int = 0
        if !enabled {
            disableCount += 1
        } else {
            disableCount = max((disableCount - 1), 0)
        }

        self.view.isUserInteractionEnabled = (disableCount == 0)
    }

    func setPaneViewControllerViewUserInteractionEnabled(_ enabled: Bool) -> Void {
        self.mainViewController?.view.isUserInteractionEnabled = enabled
    }

// MARK:- Gestures
    func isPaneDragRevealEnabledForDirection(_ direction: SSDrawerDirection) -> Bool {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts singular directions when querying for drag reveal enabled")
        var paneDragRevealEnabled: Bool = false

        if let enabled = self.paneDragRevealEnabled[direction] {
            paneDragRevealEnabled = enabled
        }

        if !paneDragRevealEnabled {
            paneDragRevealEnabled = true
        }

        return paneDragRevealEnabled
    }

    func isPaneTapToCloseEnabledForDirection(_ direction: SSDrawerDirection) -> Bool {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts singular directions when querying for drag reveal enabled")
        var paneTapToCloseEnabled: Bool = false

        if let enabled = self.paneTapToCloseEnabled[direction] {
            paneTapToCloseEnabled = enabled
        }

        if !paneTapToCloseEnabled {
            paneTapToCloseEnabled = true
        }

        return paneTapToCloseEnabled
    }

    func deltaForPanWithStartLocation(_ startLocation: CGPoint, currentLocation: CGPoint) -> CGFloat {
        var panDelta: CGFloat = 0
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            panDelta = currentLocation.x - startLocation.x
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            panDelta = currentLocation.y - startLocation.y
        }

        return panDelta
    }

    func directionForPanWithStartLocation(_ startLocation: CGPoint, currentLocation: CGPoint) -> SSDrawerDirection {
        let delta: CGFloat = self.deltaForPanWithStartLocation(startLocation, currentLocation: currentLocation)
        var direction: SSDrawerDirection = SSDrawerDirection.None

        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            if delta > 0.0 {
                direction = SSDrawerDirection.Left
            } else if delta < 0.0 {
                direction = SSDrawerDirection.Right
            }
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            if delta > 0.0 {
                direction = SSDrawerDirection.Top
            } else if delta < 0.0 {
                direction = SSDrawerDirection.Bottom
            }
        }

        return direction
    }

    func paneViewFrameForPanWithStartLocation(_ startLocation: CGPoint, currentLocation: CGPoint, bounded: inout Bool) -> CGRect {
        let panDelta: CGFloat = self.deltaForPanWithStartLocation(startLocation, currentLocation: currentLocation)
        // Track the pane frame to the pan gesture
        var paneFrame: CGRect = self.mainView.frame
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            paneFrame.origin.x += panDelta
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            paneFrame.origin.y += panDelta
        }

        // Pane view edge bounding
        var paneBoundOpenLocation: CGFloat = 0.0
        var paneBoundClosedLocation: CGFloat = 0.0
        switch self.currentDrawerDirection {
        case SSDrawerDirection.Left:
            paneBoundOpenLocation = self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.x <= paneBoundClosedLocation {
                paneFrame.origin.x = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.x >= paneBoundOpenLocation {
                paneFrame.origin.x = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Right:
            paneBoundClosedLocation = -self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.x <= paneBoundClosedLocation {
                paneFrame.origin.x = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.x >= paneBoundOpenLocation {
                paneFrame.origin.x = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Top:
            paneBoundOpenLocation = self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.y <= paneBoundClosedLocation {
                paneFrame.origin.y = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.y >= paneBoundOpenLocation {
                paneFrame.origin.y = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Bottom:
            paneBoundClosedLocation = -self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.y <= paneBoundClosedLocation {
                paneFrame.origin.y = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.y >= paneBoundOpenLocation {
                paneFrame.origin.y = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        default:
            break
        }

        return paneFrame
    }

    func velocityForPanWithStartLocation(_ startLocation: CGPoint, currentLocation: CGPoint) -> CGFloat {
        var velocity: CGFloat = 0.0
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            velocity = -(startLocation.x - currentLocation.x)
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            velocity = -(startLocation.y - currentLocation.y)
        }

        return velocity
    }

    func paneStateForPanVelocity(_ panVelocity: CGFloat) -> SSDrawerMainState {
        var state: SSDrawerMainState = .closed
        if (self.currentDrawerDirection & [SSDrawerDirection.Top, SSDrawerDirection.Left]) != SSDrawerDirection.None {
            state = (panVelocity > 0) ? .open : .closed
        } else if (self.currentDrawerDirection & [SSDrawerDirection.Bottom, SSDrawerDirection.Right]) != SSDrawerDirection.None {
            state = (panVelocity < 0) ? .open : .closed
        }

        return state
    }

    func panGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer, didStartAtEdgesOfView view: UIView) -> UIRectEdge {
        let translation: CGPoint = panGestureRecognizer.translation(in: view)
        let currentLocation: CGPoint = panGestureRecognizer.location(in: view)
        let startLocation: CGPoint = CGPoint(x: (currentLocation.x - translation.x), y: (currentLocation.y - translation.y))
        let distanceToEdges: UIEdgeInsets = UIEdgeInsets(top: startLocation.y, left: startLocation.x, bottom: (view.bounds.size.height - startLocation.y), right: (view.bounds.size.width - startLocation.x))

        var rectEdge: UIRectEdge = UIRectEdge()
        if distanceToEdges.top < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.top
        }
        if distanceToEdges.left < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.left
        }
        if distanceToEdges.right < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.right
        }
        if distanceToEdges.bottom < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.bottom
        }

        return rectEdge
    }

// MARK:- UIGestureRecognizer Callbacks
    func paneTapped(_ gesture: UITapGestureRecognizer) -> Void {
        if self.isPaneTapToCloseEnabledForDirection(self.currentDrawerDirection) {
            self.addDynamicsBehaviorsToCreatePaneState(SSDrawerMainState.closed)
        }
    }

    fileprivate var panStartLocation: CGPoint = CGPoint.zero
    fileprivate var paneVelocity: CGFloat = 0
    fileprivate var panDirection: SSDrawerDirection = SSDrawerDirection.None

    func panePanned(_ gesture: UIPanGestureRecognizer) -> Void {

        switch gesture.state {
        case UIGestureRecognizerState.began:
            // Initialize static variables
            panStartLocation = gesture.location(in: self.mainView)
            paneVelocity = 0
            panDirection = self.currentDrawerDirection
        case .changed:
            let currentPanLocation: CGPoint = gesture.location(in: self.mainView)
            let currentPanDirection: SSDrawerDirection = self.directionForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation)
            // If there's no current direction, try to determine it
            if self.currentDrawerDirection == SSDrawerDirection.None {
                var currentDrawerDirection: SSDrawerDirection = SSDrawerDirection.None
                // If a direction has not yet been previousy determined, use the pan direction
                if panDirection == SSDrawerDirection.None {
                    currentDrawerDirection = currentPanDirection
                } else {
                    // Only allow a new direction to be in the same direction as before to prevent swiping between drawers in one gesture
                    if currentDrawerDirection == panDirection {
                        currentDrawerDirection = panDirection
                    }
                }
                // If the new direction is still none, don't continue
                if currentDrawerDirection == SSDrawerDirection.None {
                    return
                }
                // Ensure that the new current direction is:
                if (self.possibleDrawerDirection & currentDrawerDirection) != SSDrawerDirection.None &&
                    self.isPaneDragRevealEnabledForDirection(currentDrawerDirection) {
                    self.currentDrawerDirection = currentDrawerDirection
                    // Establish the initial drawer direction if there was none
                    if panDirection == SSDrawerDirection.None {
                        panDirection = self.currentDrawerDirection
                    }
                }
                // If these criteria aren't met, cancel the gesture
                else {
                    gesture.isEnabled = false
                    gesture.isEnabled = true
                    return
                }
            }
            // If the current reveal direction's pane drag reveal is disabled, cancel the gesture
            else if !self.isPaneDragRevealEnabledForDirection(self.currentDrawerDirection) {
                gesture.isEnabled = false
                gesture.isEnabled = true
                return
            }

            // At this point, panning is able to move the pane independently from the dynamic animator, so remove all behaviors to prevent conflicting frames
            self.dynamicAnimator?.removeAllBehaviors()

            // Update the pane frame based on the pan gesture
            var paneViewFrameBounded: Bool = false
            self.mainView.frame = self.paneViewFrameForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation, bounded: &paneViewFrameBounded)

            // Update the pane velocity based on the pan gesture
            let currentPaneVelocity: CGFloat = self.velocityForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation)

            // If the pane view is bounded or the determined velocity is 0, don't update it
            if !paneViewFrameBounded && (currentPaneVelocity != 0.0) {
                paneVelocity = currentPaneVelocity
            }

            // If the drawer is being swiped into the closed state, set the direciton to none and the state to closed since the user is manually doing so
            if self.currentDrawerDirection != SSDrawerDirection.None &&
                currentPanDirection != SSDrawerDirection.None &&
                self.mainView.frame.origin.equalTo(self.paneViewOriginForPaneState(SSDrawerMainState.closed)) {
                self._setMainState(SSDrawerMainState.closed)
                self.currentDrawerDirection = SSDrawerDirection.None
            }
        case .ended:
            if self.currentDrawerDirection != SSDrawerDirection.None {
                // If the user released the pane over the velocity threshold
                if fabs(paneVelocity) > SSPaneViewVelocityThreshold {
                    let state: SSDrawerMainState = self.paneStateForPanVelocity(paneVelocity)
                    self.addDynamicsBehaviorsToCreatePaneState(state, pushMagnitude: fabs(paneVelocity) * SSPaneViewVelocityMultiplier, pushAngle: self.gravityAngleForState(state, direction: self.currentDrawerDirection), pushElasticity: self.elasticity)
                }
                // If not released with a velocity over the threhold, update to nearest `paneState`
                else {
                    self.addDynamicsBehaviorsToCreatePaneState(self.nearestPaneState())
                }
            }
        default:
            break
        }
    }

// MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === self.panePanGestureRecognizer {
            if self.paneDragRequiresScreenEdgePan {
                var paneState: SSDrawerMainState = .closed
                if self.paneViewIsPositionedInValidState(&paneState) && (paneState == .closed) {
                    let panStartEdges: UIRectEdge = self.panGestureRecognizer(self.panePanGestureRecognizer!, didStartAtEdgesOfView: self.mainView)

                    // Mask to only edges that are possible (there's a drawer view controller set in that direction)
                    let possibleDirectionsForPanStartEdges: SSDrawerDirection = SSDrawerDirection(rawValue: panStartEdges.rawValue & self.possibleDrawerDirection.rawValue)
                    let gestureStartedAtPossibleEdge: Bool = possibleDirectionsForPanStartEdges.rawValue != UIRectEdge().rawValue

                    // If the gesture didn't start at a possible edge, return no
                    if !gestureStartedAtPossibleEdge {
                        return false
                    }
                }
            }

            guard let beginable = self.delegate?.drawerViewController(self, shouldBeginPanePan: self.panePanGestureRecognizer!) else {
                return true
            }

            if !beginable {
                return false
            }
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer === self.panePanGestureRecognizer {
            var shouldReceiveTouch: Bool = true

            // Enumerate the view's superviews, checking for a touch-forwarding class
            touch.view?.superviewHierarchyAction({ [weak self] (view) in
                guard let wself = self else { return }

                // Only enumerate while still receiving the touch
                if !shouldReceiveTouch {
                    return
                }
                // If the touch was in a touch forwarding view, don't handle the gesture
                wself.touchForwardingClasses.enumerateObjects({ (touchForwardingClass, stop) in
                    if view.isKind(of: touchForwardingClass as! AnyClass) {
                        shouldReceiveTouch = false
                        stop.pointee = true
                    }
                })
            })

            return shouldReceiveTouch
        } else if gestureRecognizer === self.paneTapGestureRecognizer {
            var paneState: SSDrawerMainState = .closed
            if self.paneViewIsPositionedInValidState(&paneState) {
                return paneState != .closed
            }
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer === self.panePanGestureRecognizer) && self.screenEdgePanCancelsConflictingGestures {
            let edges: UIRectEdge = self.panGestureRecognizer(self.panePanGestureRecognizer!, didStartAtEdgesOfView: self.mainView)

            // Mask out edges that aren't possible
            let validEdges: Bool = (edges.rawValue & self.possibleDrawerDirection.rawValue) != 0

            // If there is a valid edge and pane drag is revealed for that edge's direction
            if validEdges && self.isPaneDragRevealEnabledForDirection(SSDrawerDirection(rawValue: validEdges ? 1 : 0)) {
                return true
            }
        }

        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        // If the other gesture recognizer's view is a `UITableViewCell` instance's internal `UIScrollView`, require failure
        if let view = otherGestureRecognizer.view {
            if view.next is UITableViewCell && view is UIScrollView {
                return true
            }
        }
        
        return false
    }

// MARK: - NSKeyValueObserving
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let view = object as? UIView {
            if (keyPath == "frame") && (view === self.mainView) {
                if let _ = (object as AnyObject).value(forKey: keyPath!) {
                    self.paneViewDidUpdateFrame()
                }
            }
        }
    }
}

typealias ViewActionBlock = (_ view: UIView) -> Void

extension UIView {
    func superviewHierarchyAction(_ viewAction: ViewActionBlock) -> Void {
        viewAction(self)
        self.superview?.superviewHierarchyAction(viewAction)
    }
}
