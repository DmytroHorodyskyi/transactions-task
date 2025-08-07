//
//  AppDelegate.swift
//  TransactionsTestTask
//
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let servicesAssembler = ServicesAssembler()
        let rootNavigationViewController = UINavigationController(
            rootViewController: MainViewController(servicesAssembler: servicesAssembler)
        )
        rootNavigationViewController.navigationBar.tintColor = .black
        window.rootViewController = rootNavigationViewController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
