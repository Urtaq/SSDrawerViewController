//
//  SSDrawerStyler.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 18..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSDrawerStyler: class {

    static func styler() -> SSDrawerStyler
    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) -> Void

    func stylerWasAddedToDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) -> Void
    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) -> Void

//    @available(*, deprecated=1.0, obsoleted=2.0, message="Trying to avoid using this!!")
//    func stylerWasAddedToDrawerViewController(drawerViewController: SSDrawerViewController) -> Void
//    @available(*, deprecated=1.0, obsoleted=2.0, message="Trying to avoid using this!!")
//    func stylerWasRemovedFromDrawerViewController(drawerViewControler: SSDrawerViewController) -> Void
}

extension SSDrawerStyler {
    

    func stylerWasAddedToDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) -> Void {

    }
    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) -> Void {

    }
}

class SSDrawerParallaxStyler: SSDrawerStyler {
    var parallaxOffsetFraction: CGFloat = 0.0

    init() {
        self.parallaxOffsetFraction = 0.35
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerParallaxStyler()
    }

    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) {
        let mainRevealWidth: CGFloat = drawerViewController.revealWidthForDirection(direction)
        var translate: CGFloat = (mainRevealWidth * paneClosedFraction) * self.parallaxOffsetFraction
        if (direction & [SSDrawerDirection.Top, SSDrawerDirection.Left]) != SSDrawerDirection.None {
            translate = -translate;
        }
        var drawerViewTransform: CGAffineTransform = drawerViewController.drawerView.transform
        if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            drawerViewTransform.tx = CGAffineTransform(translationX: CGFloat(translate), y: 0).tx
        } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            drawerViewTransform.ty = CGAffineTransform(translationX: 0.0, y: CGFloat(translate)).ty;
        } else {
            drawerViewTransform.tx = 0;
            drawerViewTransform.ty = 0;
        }
        drawerViewController.drawerView.transform = drawerViewTransform;
    }

    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) {
        let translate: CGAffineTransform = CGAffineTransform(translationX: 0.0, y: 0.0)
        var drawerViewTransform: CGAffineTransform = drawerViewController.drawerView.transform
        drawerViewTransform.tx = translate.tx
        drawerViewTransform.ty = translate.ty
        drawerViewController.drawerView.transform = drawerViewTransform
    }
}

class SSDrawerFadeStyler: SSDrawerStyler {
    var closeAlpha: CGFloat = 0.0

    static func styler() -> SSDrawerStyler {
        return SSDrawerFadeStyler()
    }

    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) {
        if (direction & SSDrawerDirection.All) != SSDrawerDirection.None {
            drawerViewController.drawerView.alpha = (1.0 - self.closeAlpha) * (1.0 - paneClosedFraction)
        } else {
            drawerViewController.drawerView.alpha = 1.0
        }
    }

    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) {
        drawerViewController.drawerView.alpha = 1.0
    }
}

class SSDrawerScaleStyler: SSDrawerStyler {
    var closedScale: CGFloat = 0.0

    init() {
        self.closedScale = 0.1
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerScaleStyler()
    }

    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) {
        var scale: CGFloat = 0.0
        if (direction & SSDrawerDirection.All) != SSDrawerDirection.None {
            scale = 1.0 - paneClosedFraction * self.closedScale
        } else {
            scale = 1.0
        }
        let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: scale, y: scale)
        var drawerViewTransform: CGAffineTransform = drawerViewController.drawerView.transform
        drawerViewTransform.a = scaleTransform.a
        drawerViewTransform.d = scaleTransform.d
        drawerViewController.drawerView.transform = drawerViewTransform
    }
}

class SSDrawerResizeStyler: SSDrawerStyler {
    var minimumResizeRevealWidth: CGFloat {
        get {
            return self.minimumResizeRevealWidth
        }
        set {
            if newValue == 0.0 {
                self.useRevealWidthAsMinimumResizeRevealWidth = true
            } else {
                self.useRevealWidthAsMinimumResizeRevealWidth = false
            }
            self.minimumResizeRevealWidth = newValue
        }
    }
    var useRevealWidthAsMinimumResizeRevealWidth: Bool

    init() {
        self.useRevealWidthAsMinimumResizeRevealWidth = true
        self.minimumResizeRevealWidth = 0.0
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerResizeStyler()
    }

    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) {
        if direction == SSDrawerDirection.None {
            return
        }

        var drawerViewFrame: CGRect = drawerViewController.drawerViewControllerForDirection(direction)!.view.frame
        let minimumResizeRevealWidth: CGFloat = self.useRevealWidthAsMinimumResizeRevealWidth ? drawerViewController.revealWidthForDirection(direction) : self.minimumResizeRevealWidth
        if drawerViewController.currentRevealWidth() < minimumResizeRevealWidth {
            drawerViewFrame.size.width = drawerViewController.revealWidthForDirection(direction)
        } else {
            if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                drawerViewFrame.size.width = CGFloat(drawerViewController.currentRevealWidth())
            } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                drawerViewFrame.size.height = CGFloat(drawerViewController.currentRevealWidth())
            }
        }

        let paneViewFrame: CGRect = (drawerViewController.mainView.frame)
        switch direction {
        case SSDrawerDirection.Right:
            drawerViewFrame.origin.x = paneViewFrame.maxX
        case SSDrawerDirection.Bottom:
            drawerViewFrame.origin.y = paneViewFrame.maxY
        default:
            break
        }

        drawerViewController.drawerViewControllerForDirection(direction)?.view.frame = drawerViewFrame
    }

    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) {
        // Reset the drawer view controller's view to be the size of the drawerView (before the styler was added)
        var drawerViewFrame: CGRect = (drawerViewController.drawerViewControllerForDirection(direction)?.view.frame)!
        drawerViewFrame.size = (drawerViewController.drawerView.frame.size)
        drawerViewController.drawerViewControllerForDirection(direction)?.view.frame = drawerViewFrame
    }
}

class SSDrawerShadowStyler: SSDrawerStyler {
    var shadowColor: UIColor = UIColor.black {
        didSet {
            if shadowColor != oldValue {
                shadowLayer?.shadowColor = shadowColor.cgColor
            }
        }
    }
    var shadowRadius: CGFloat = 10.0 {
        didSet {
            if shadowRadius != oldValue {
                shadowLayer?.shadowRadius = shadowRadius
            }
        }
    }
    var shadowOpacity: Float = 1.0 {
        didSet {
            if shadowOpacity != oldValue {
                shadowLayer?.shadowOpacity = shadowOpacity
            }
        }
    }
    var shadowOffset: CGSize = CGSize.zero {
        didSet {
            if shadowOffset == oldValue {
                shadowLayer?.shadowOffset = shadowOffset
            }
        }
    }
    var shadowLayer: CALayer?

    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil, queue: nil) { (notification) in
            self.shadowLayer?.removeFromSuperlayer()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerShadowStyler()
    }

    func stylerWasAddedToDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) {
        self.shadowLayer = CALayer()
        self.shadowLayer?.shadowPath = UIBezierPath(rect: drawerViewController.mainView.frame).cgPath
        self.shadowLayer?.shadowColor = self.shadowColor.cgColor
        self.shadowLayer?.shadowOpacity = self.shadowOpacity
        self.shadowLayer?.shadowRadius = self.shadowRadius
        self.shadowLayer?.shadowOffset = self.shadowOffset
    }

    func styleDrawerViewController(_ drawerViewController: SSDrawerViewController, didUpdatePaneClosedFraction paneClosedFraction: CGFloat, forDirection direction: SSDrawerDirection) {
        if (direction & SSDrawerDirection.All) != SSDrawerDirection.None {
            if self.shadowLayer?.superlayer == nil {
                let paneViewSize: CGSize = drawerViewController.mainView.frame.size
                var shadowRect: CGRect = CGRect(x: 0, y: 0, width: paneViewSize.width, height: paneViewSize.height)
                if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                    shadowRect = shadowRect.insetBy(dx: 0.0, dy: -self.shadowRadius)
                } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                    shadowRect = shadowRect.insetBy(dx: -self.shadowRadius, dy: 0.0)
                }
                self.shadowLayer?.shadowPath = UIBezierPath(rect: shadowRect).cgPath
                drawerViewController.mainView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }
        } else {
            self.shadowLayer?.removeFromSuperlayer()
        }
    }

    func stylerWasRemovedFromDrawerViewController(_ drawerViewController: SSDrawerViewController, forDirection direction: SSDrawerDirection) {
        self.shadowLayer?.removeFromSuperlayer()
        self.shadowLayer = nil
    }
}
