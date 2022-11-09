//
//  Project_BirdApp.swift
//  Shared
//
//  Created by Marcos Chevis on 08/08/22.
//

import SwiftUI
import AppFeature
import Tweet

@main
struct Project_BirdApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private var delegate: NotificationDelegate = NotificationDelegate()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
