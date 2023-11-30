//
//  VerificationCodeInputView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/12/23.
//

import SwiftUI

struct VerificationCodeInputView: View {
    @State private var verificationCode = ""
    @Binding var isPhoneVerified: Bool
    @Binding var isPresented: Bool

       var body: some View {
           VStack {
               Text("We've sent verification code to your L&I phone number. Make sure your number is up to date.")
               TextField("Enter Code", text: $verificationCode)
                           .keyboardType(.numberPad) // Set keyboard to number pad
                           .onReceive(verificationCode.publisher.collect()) {
                               // Limit the input to 6 digits
                               self.verificationCode = String($0.prefix(6))
                           }
                           .multilineTextAlignment(.center) // Center align text
                           .font(.title) // Increase font size
                           .frame(maxWidth: 200) // Set a max width for the TextField
                           .padding()
                           .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

               Button(action:{
                   NetworkManager.shared.verifyPhoneNumber(code: verificationCode) {success in
                       if success{
                           print("Phone is verified! NOW user can use the app!")
                           isPhoneVerified = true
                           isPresented = false
                       }
                   }
               })
               {
                   Text("Verify Code")
                   
               }
               .padding()
           }
       }
}

struct VerificationCodeInputView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isPhoneVerified = false
        @State var isPresented = false
        VerificationCodeInputView(isPhoneVerified: $isPhoneVerified, isPresented: $isPresented)
    }
}
