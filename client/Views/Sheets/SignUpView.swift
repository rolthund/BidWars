//
//  SignUpView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/29/23.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sign Up")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                if showAlert {
                    Text("Incorrect email or passwors. Please try again.")
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Section {
                    Button(action: {
                        AuthManager.shared.signUp(email: email, password: password, name: name, phone: phone) { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Sign-Up Failed"),
                            message: Text("Please check your email and password and try again."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .padding()
            .navigationBarTitle("Sign Up")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
                .foregroundColor(.brandPrimary)
            )
        }.background()
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
