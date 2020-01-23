//
//  AppDelegate.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import UIKit

func create() -> VideoService {
    let url = Bundle.main.path(forResource: "Funny Cartoon1", ofType: "mp4") ?? ""
    return VideoServiceImpl(url: URL(fileURLWithPath: url))
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var frameListPresenter = FrameListPresenter(interactor: FrameListInteractorImpl(videoService: create()))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let controller = FrameListViewController()

        frameListPresenter.observe(controller.render)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        return true
    }

}

