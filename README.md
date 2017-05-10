# SSDrawerViewController

[![Swift](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)](https://swift.org)

## What is this for?
[MSDynamicDrawerViewController](https://github.com/erichoracek/MSDynamicsDrawerViewController) is written in Objective-C.
So, I convert it and write in Swift.  
This is integrated with UIKit Dynamics APIs(new in iOS7).  
For a detail, you can refer the [MSDynamicDrawerViewController](https://github.com/erichoracek/MSDynamicsDrawerViewController).

## Requirements

* iOS 8.1+
* Swift 3.0+

## Installation

### Manual Import

Just drag these sources into your project.  
I'll support [Cocoapods]((https://github.com/CocoaPods/CocoaPods)) or [Carthage](https://github.com/Carthage/Carthage) ASAP.

## Usage

The usage of SSDrawerViewController is same with [MSDynamicDrawerViewController](https://github.com/erichoracek/MSDynamicsDrawerViewController).  
But, compared to [MSDynamicDrawerViewController](https://github.com/erichoracek/MSDynamicsDrawerViewController), SSDrawerViewController is written in Swift.  
As a result, the usage is slightly different depends on each language's syntax.

So, I'd like to share my use case in Swift 3.

```swift
// AppDelegate.swift

class AppDelegate: UIResponder, UIApplicationDelegate, SSDrawerViewControllerDelegate {
    ...
    var window: UIWindow?
    var drawerController: SSDrawerViewController?
    var isDrawable: Bool = true
    ...

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    ...
        // DrawerViewController
        self.drawerController = self.window!.rootViewController as? SSDrawerViewController
        self.drawerController?.delegate = self
        self.drawerController?.addStylerFromArray([SSDrawerScaleStyler.styler(), SSDrawerFadeStyler.styler(), SSDrawerShadowStyler.styler()], forDirection: SSDrawerDirection.Left)

        let menuViewController: SSMenuViewController = (self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? SSMenuViewController)!
        menuViewController.drawerViewController = self.drawerController
        self.drawerController?.setDrawerViewController(menuViewController, forDirection: SSDrawerDirection.Left)

        // Transition to the first view controller
        menuViewController.transitionToViewController()

        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()
    ...
    }
    
    ...
    
// MARK: - SSDrawerViewControllerDelegate

    func drawerViewController(_ drawerViewController: SSDrawerViewController, mayUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller may update to state `\(paneState)` for direction `\(direction)`")

        if paneState == .open {
            if let menuViewController = drawerViewController.drawerViewController as? SSMenuViewController {
                if let headerView = menuViewController.menuTableView.headerView(forSection: 0) as? SSMenuHeadView {
                    headerView.configView()
                }
            }
        }
    }

    func drawerViewController(_ drawerViewController: SSDrawerViewController, didUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller did update to state `\(paneState)` for direction `\(direction)`")
    }

    func drawerViewController(_ drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return self.isDrawable
    }
}
```

```swift
// SSMenuViewController.swift

class SSMenuViewController: UIViewController {
    ...
    weak var drawerViewController: SSDrawerViewController?
    ...
    func transitionToViewController() -> Void {
        let animateTransition: Bool = self.drawerViewController?.mainViewController != nil

        let mainNavigationController: UINavigationController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MasterNavigationController") as? UINavigationController)!

        self.drawerViewController?.setMainViewController(mainNavigationController, animated: animateTransition, completion: nil)
    }
}
```

## License

SSDrawerViewController is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
