//
//  AppDelegate.swift
//  ReorderableGridView
//
//  Created by Harvey Zhang on 19/11/14.
//  Copyright (c) 2017 Happy Guy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		let aFont = UIFont.HelveticaNeue(type: UIFont.FontType.Thin, size: 20)
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: aFont]
		
		return true
	}

}
