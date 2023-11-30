//
//  AddProjectView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/25/23.
//

import SwiftUI

struct AddProjectView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @Binding var isSheetPresented: Bool
    @Binding var isCreatedSuccessfully:Bool
    @State private var tradeArray = Util.util.getTrades()
    
    @State private var isButtonTapped = false
    @State private var showSuccessAlert = false
    @State private var showFailAlert = false
    
    @State private var name = ""
    @State private var description = ""
    @State private var location = ""
    @State private var trade = "General"
    @State private var bidable = false
    @State private var start_date = Date()
    
    private var isFormValid: Bool {
        ![name, location, trade, description].contains(where: { $0.isEmpty })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Form{
                Section(header: Text("Add new project")) {
                    TextField("Project Name", text: $name)
                        .fontWeight(.semibold)
                    Picker(selection: self.$trade, label: Text("Trade")) {
                        ForEach(tradeArray, id: \.self) { trade in
                            Text(trade)
                        }
                    }.foregroundColor(.brandPrimary)
                    
                    TextField("Location", text: $location)
                    
                    DatePicker("Estimated start date", selection: $start_date, displayedComponents: .date)
                        .onChange(of: start_date) { newDate in
                            // Adjust the time component after the date is picked
                            // Here, setting the time to 8:00 AM as an example
                            let calendar = Calendar.current
                            if let adjustedDateTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: newDate) {
                                start_date = adjustedDateTime
                            }
                        }
                        .accentColor(.brandPrimary)
                        .foregroundColor(.brandPrimary)
                    
                }
                
                PlaceholderTextEditor(placeholder: "Please describe your project here", text: $description)
                    .frame(minHeight: 200)
                    .padding(4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding()
                
                
                ZStack{
                    HStack{
                        Spacer()
                        Button(action: {
                            print(start_date)
                            isButtonTapped = true
                            projectViewModel.createNewProject(name: name, description: description, trade: trade, location: location, start_date: start_date, bidable: bidable) { success in
                                if success{
                                    showSuccessAlert = true
                                    isCreatedSuccessfully = true
                                } else {
                                    showFailAlert = true
                                }
                            }
                        }) {
                            Text("Add Project")
                                .foregroundColor(.white)
                                .padding()
                                .background(isFormValid ? Color.brandPrimary : Color.gray)
                                .cornerRadius(10)
                            
                        }
                        .disabled(!isFormValid)
                        
                        Spacer()
                    }
                }
            }
        }
        .overlay(EmptyView()
            .alert(isPresented: $isButtonTapped){
                Alert(title: Text("Allow contractors to bid?"),
                      message: Text("Do you want your contractors to be able to bid for this project (you can always allow this later)."),
                      primaryButton: .default(Text("Allow"), action: {bidable = true; isSheetPresented = false}),
                      secondaryButton: .default(Text("Don't allow"), action: {bidable = false; isSheetPresented = false})
                )
            })
        .overlay(
            EmptyView()
                .alert(isPresented: $showSuccessAlert){
                    Alert(title: Text("Created!"), message: Text("Project successfully created"), dismissButton: .default(Text("OK")))
                }
        )
        .overlay(
            EmptyView()
                .alert(isPresented: $showFailAlert){
                    Alert(title: Text("Error"), message: Text("An error occured while creating project, please try again"), dismissButton: .default(Text("OK")))
                }
        )
    }
}

struct PlaceholderTextEditor: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            
            TextEditor(text: $text)
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isPresented = false
        @State var isCreatedSuccessfully = false
        AddProjectView(isSheetPresented: $isPresented, isCreatedSuccessfully: $isCreatedSuccessfully)
    }
}
