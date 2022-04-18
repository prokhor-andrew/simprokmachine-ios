//
//  AppDelegate.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = MainViewController()
        
        start()
        
        return true
    }
}


extension AppDelegate: RootMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent

    var child: Machine<AppEvent, AppEvent> {
        .merge(
            ~Domain(),
            ~Display()
        ).redirect { .back($0) }
    }
}
