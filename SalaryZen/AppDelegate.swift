//
//  AppDelegate.swift
//  SalaryZen
//
//  Created by Sergey Lukjanov on 11/01/15.
//  Copyright (c) 2015 Sergey Lukjanov. All rights reserved.
//

import UIKit

import Parse
import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        ParseCrashReporting.enable();
        Parse.setApplicationId("cvN6yxnFKXaNxe0WypJSH1o0RGpg03LNCGcIwlqY",
            clientKey:"jjHXsi0efm84vCTIn7kRqiy91Nl0yh6Q4M5oq8BG")

        return true
    }
}

