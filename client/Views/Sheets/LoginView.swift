//
//  LoginView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/29/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Log In")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                }
                
                if showAlert {
                    Text("Incorrect email or passwors. Please try again.")
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Section {
                    Button(action: {
                        AuthManager.shared.login(email: email, password: password) { success in
                            if success {
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(10)
                    }.alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Login Failed"),
                            message: Text("Please check your email and password and try again."),
                            dismissButton: .default(Text("OK"))
                        )
                        }
                    }
            }
            .padding()
            .navigationBarTitle("Log In")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.brandPrimary) // Set the button's text color to green
            )
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

