//
//  LicenseFormView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 10/1/23.
//

import SwiftUI

struct LicenseFormView: View {
    
        @Binding var isPresented: Bool
        @Binding var showVerifyNumber: Bool
        @State private var UBI_number = ""
        @State private var licenseNumber = ""
        @State private var isInsuranceExpired = false
        @State private var isLicenseExpired = false
    
        @State private var showVerificationAlert = false
        @State private var showUpdatingAlert = false
        @State private var isVerified = false
    
        @State private var showProgressView = false
    
    
    private var isFormValid: Bool {
        ![UBI_number, licenseNumber].contains(where: { $0.isEmpty })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Form{
                Section(header: Text("Edit License Information")) {
                    TextField("UBI Number", text: $UBI_number)
                    TextField("License Number", text: $licenseNumber)
                }
                
                
                ZStack{
                    HStack{
                        Spacer()
                        Button(action: {
                            verifyLicense()
                        }) {
                            Text("Submit")
                                .foregroundColor(.white)
                                .padding()
                                .background(isFormValid ? Color.brandPrimary : Color.gray)
                                .cornerRadius(10)
                            
                        }
                        .disabled(!isFormValid)
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .overlay(
                        EmptyView()
                            .alert(isPresented: $showVerificationAlert){
                                Alert(
                                    title: Text("Verification Failed"),
                                    message: Text("Please check your license information and try again."),
                                    dismissButton: .default(Text("OK"))
                                )
                            })
                    .overlay(
                        EmptyView()
                            .alert(isPresented: $showUpdatingAlert){
                                Alert(
                                    title: Text("Failed to save changes"),
                                    message: Text("Something wrong with the app, try again later"),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                    )
                    
                    
                    if(showProgressView == true) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2) // Makes the progress view larger
                            .padding()
                    }
                }
            }
            
        }
        .padding()
        .background()
        .cornerRadius(16)
    }
    
    private func verifyLicense(){
        showProgressView = true
        
        NetworkManager.shared.verifyLicense(UBI_number: UBI_number, license_number: licenseNumber){success in
            if success{
                print("Success Verifying")
                NetworkManager.shared.updateLicense(UBI_number: UBI_number, license_number: licenseNumber) {updateSucc in
                    if updateSucc {
                        showVerifyNumber = true
                        showProgressView = false
                        isPresented = false
                    } else {
                        showUpdatingAlert = true
                    }
                }
            } else {
                showVerificationAlert = true
            }
            showProgressView = false
        }
    }
}

struct LicenseFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        @State var isEditing = true
        @State var showVerifyNumber = false
        LicenseFormView(isPresented: $isEditing, showVerifyNumber: $showVerifyNumber)
    }
}
