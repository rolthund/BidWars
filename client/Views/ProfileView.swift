//
//  ProfileView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/4/23.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @State var builder:Builder
    @State private var notificationToggle: Bool = false
    @State private var locationUsage: Bool = false
    @State private var isLicenseFormPresent = false
    @State private var showVerifyNumber = false
    @State private var isPhoneVerified = false
    @State private var username: String = "James"
    @State private var selectedState: String = "WA"
    @State private var unabledStates: Set<String> = ["WA"]
    @State private var selectedTrade: String = "General"
    
    @State private var stateArray: [String] = Util.util.getStates()
    @State private var tradeArray:[String] = Util.util.getTrades()
    
    var body: some View {
        ZStack{
            
            GeometryReader { g in
                VStack {
                    Image("italy")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .background(Color.yellow)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                    Text("John Appleseed")
                        .font(.system(size: 20))
                    
                    Form {
                        
                        Section(header: Text("License Information")) {
                            Picker(selection: self.$selectedState, label: Text("State")) {
                                ForEach(stateArray, id: \.self) { state in
                                    if(unabledStates.contains(state)){
                                        Text(state)
                                            .tag(state)
                                    }
                                }
                            }
                            
                            Picker(selection: self.$selectedTrade, label: Text("Trade")) {
                                ForEach(tradeArray, id: \.self) { trade in
                                    if(trade == "General"){
                                        Text(trade)
                                    }
                                    
                                }
                            }
                            
                            Button(action: {
                                print("Button tapped")
                                isLicenseFormPresent.toggle()
                            }
                                   
                            ) {
                                Text("Add/Edit license information")
                            }
                            
                        }
                        
                        
                        
                        Section(header: Text("Personal Information")) {
                            NavigationLink(destination: Text("Profile Info")) {
                                Text("Profile Information")
                            }
                            
                            NavigationLink(destination: Text("Billing Info")) {
                                Text("Billing Information")
                            }
                        }
                        
                        Section(footer: Text("Allow push notifications to get latest travel and equipment deals")) {
                            Toggle(isOn: self.$locationUsage) {
                                Text("Location Usage")
                            }
                            Toggle(isOn: self.$notificationToggle) {
                                Text("Notifications")
                            }
                        }
                        
                    }.background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                        .navigationBarTitle("Settings")
                }
                if isLicenseFormPresent{
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isLicenseFormPresent.toggle()
                        }
                    VStack {
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            LicenseFormView(isPresented: $isLicenseFormPresent, showVerifyNumber: $showVerifyNumber)
                                .frame(width: 300, height: 280)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .transition(.scale)
                                .ignoresSafeArea(.all)
                            
                            Spacer()
                       }
                        
                        
                       
                        Spacer()
                    }
                    
                    
                }
                
                if showVerifyNumber{
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showVerifyNumber.toggle()
                        }
                    VStack {
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VerificationCodeInputView(isPhoneVerified: $isPhoneVerified, isPresented: $showVerifyNumber)
                                .frame(width: 300, height: 360)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .transition(.scale)
                                .ignoresSafeArea(.all)
                            
                            Spacer()
                       }
                        
                        
                       
                        Spacer()
                    }
                }
            }
            
        }
        .alert(isPresented: $isPhoneVerified){
            Alert(
                title: Text("License verified!"),
                message: Text("Congratulations! Your license successefully verified and now you ready to use the app"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
 }



struct Previews_ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        let builder = Builder(
            user_id: "2",
            name: "GR",
            email: "GR@gmail.com",
            phone: "5657",
            project: [],
            license: License(UBI_number: "Asd", license_number: "S", insurance: "ASd", bond: "AS", isInsuranceExpired: false, isLicenseExpired: false)
        )
        ProfileView(builder: builder)
    }
}
