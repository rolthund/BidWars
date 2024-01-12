//
//  MainView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/5/23.
//

import SwiftUI

struct MainView: View {
    
    @State private var isSignUpSheetPresent = false
    @State private var isLoginSheetPresent = false
    
    
    var body: some View {
        ZStack {
            
            Image("logo_transparent_background")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .offset(y: -170)
            
            VStack {
                Text("Welcome to Bidwars! ")
                    .font(.title)
                    .padding()
                Text("The App that makes constraction \nnetworking easier! \n\n")
                    .foregroundColor(.secondary)
    
                
                HStack(spacing: 20) {
                    Button(action: {
                        isSignUpSheetPresent.toggle()
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.brandPrimary.opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isLoginSheetPresent.toggle()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(10)
                    }
                }
            }.padding(.bottom, 4)
        }
        .sheet(isPresented: $isSignUpSheetPresent) {
            SignUpView()
        }
        .sheet(isPresented: $isLoginSheetPresent) {
            LoginView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
