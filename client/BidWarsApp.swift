//
//  BidWarsApp.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/4/23.
//

import SwiftUI

@main
struct BidWarsApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    var body: some Scene {
        WindowGroup {
            if isLoggedIn{
                AppTabView()
            } else {
                MainView()
            }
        }
    }
}
