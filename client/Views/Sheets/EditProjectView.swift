//
//  EditProjectView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 12/2/23.
//

import SwiftUI

struct EditProjectView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @ObservedObject var project: Project
    
    @Binding var isSheetPresented: Bool
    @Binding var isUpdatedSuccessfully:Bool
    @State private var tradeArray = Util.util.getTrades()
    
    @State private var showFailAlert = false
    
    private var isFormValid: Bool {
        ![project.name, project.location, project.trade, project.description].contains(where: { $0.isEmpty })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Form{
                Section(header: Text("Edit project")) {
                    TextField("Project Name", text: $project.name)
                        .fontWeight(.semibold)
                    Picker(selection: self.$project.trade, label: Text("Trade")) {
                        ForEach(tradeArray, id: \.self) { trade in
                            Text(trade)
                        }
                    }.foregroundColor(.brandPrimary)
                    
                    TextField("Location", text: $project.location)
                    
                    DatePicker("Estimated start date", selection: $project.start_date, displayedComponents: .date)
                        .onChange(of: project.start_date) { newDate in
                            // Adjust the time component after the date is picked
                            // Here, setting the time to 8:00 AM as an example
                            let calendar = Calendar.current
                            if let adjustedDateTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: newDate) {
                                project.start_date = adjustedDateTime
                            }
                        }
                        .accentColor(.brandPrimary)
                        .foregroundColor(.brandPrimary)
                    
                }
                
                PlaceholderTextEditor(placeholder: "Please describe your project here", text: $project.description)
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
                            projectViewModel.updateProject(project_id: project.id, name: project.name, description: project.description, trade: project.trade, location: project.location, start_date: project.start_date, bidable: project.bidable) { success in
                                if success{
                                    isUpdatedSuccessfully = true
                                    isSheetPresented = false
                                } else {
                                    showFailAlert = true
                                }
                            }
                        }) {
                            Text("Save Changes")
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
        .overlay(
            EmptyView()
                .alert(isPresented: $isUpdatedSuccessfully){
                    Alert(title: Text("Updated!"), message: Text("Project successfully updated"), dismissButton: .default(Text("OK")))
                }
        )
        .overlay(
            EmptyView()
                .alert(isPresented: $showFailAlert){
                    Alert(title: Text("Error"), message: Text("An error occured while updating project, please try again"), dismissButton: .default(Text("OK")))
                }
        )
    }
}


struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isPresented = false
        @State var isUpdatedSuccessfully = false
        let project = Project(
            id: "35463",
            builder_id: "123",
            name:"Project 1",
            description: "4000sf 2 story house 7 inch hardie siding and prewrap" ,
            trade: "Siding",
            location: "Seattle",
            bidable: false,
            start_date: Date()
        )
        EditProjectView(project: project, isSheetPresented: $isPresented, isUpdatedSuccessfully: $isUpdatedSuccessfully)
    }
}
