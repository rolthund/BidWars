//
//  AppTabView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/4/23.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            ProjectListView()
                .tabItem {
                    Label("Projects", systemImage: "list.bullet")
                }
                .environmentObject(ProjectViewModel())
                
            ContractorListView()
                .tabItem {
                    Label("Contractors", systemImage: "person.fill.checkmark")
                }
            
            ProfileView(builder: NetworkManager.shared.getBuilderFromDefaults()!)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .accentColor(.brandPrimary)
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
