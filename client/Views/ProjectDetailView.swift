//
//  ProjectDetailView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/19/23.
//

import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    @State var project: Project
    @State var bidable: Bool
    @State private var isEditPresented = false
    @State private var editSuccess = false
    @State private var isBidableToggled = false
    @State private var showBidableToggleFailAlert = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                HStack{
                    Spacer()
                    Text(project.name)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Text(project.description)
                    .padding()
                
                HStack{
                    Text("Location: " )
                        .fontWeight(.semibold)
                    Text(project.location)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPrimary)
                }
                .padding()
                
                HStack{
                    Text("Estimated starting day: " )
                        .fontWeight(.semibold)
                    Text(Util.util.dateToString(project.start_date))
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPrimary)
                }
                .padding()
                
                HStack{
                    Text("Trade: " )
                        .fontWeight(.semibold)
                    Text(project.trade)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPrimary)
                }
                .padding()
                
                
                
                Spacer()
                    Section(footer: Text("Allow your contractors with matching trade to bid on this project.")) {
                        Toggle(isOn: $project.bidable) {
                            Text("Allow Bidding")
                                .fontWeight(.semibold)
                        }
                        .onChange(of: project.bidable){newValue in
                                projectViewModel.updateProject(project_id: project.id, name: project.name, description: project.description, trade: project.trade, location: project.location, start_date: project.start_date, bidable: newValue){success in
                                    if success{
                                        isBidableToggled = true
                                        projectViewModel.fetchProjects()
                                    }else{
                                        showBidableToggleFailAlert = true
                                    }
                                }
                        }
                }
                    .padding(.horizontal)
            }
            .navigationBarTitle("Project Details", displayMode: .inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditPresented = true
                    }
                }
            }
            .sheet(isPresented: $isEditPresented){
                EditProjectView(project: project, isSheetPresented: $isEditPresented, isUpdatedSuccessfully: $editSuccess)
            }
            .overlay(EmptyView()
                .alert(isPresented: $isBidableToggled){
                    Alert(title: Text("Bidding change!"),
                          message: Text("Your contractors ability to bid for the \(project.name) has chanched."),
                          dismissButton: .default(Text("OK"))
                    )
                })
            .overlay(EmptyView()
                .alert(isPresented: $showBidableToggleFailAlert){
                    Alert(title: Text("Error changing bidding."),
                          message: Text("An error has occured while changing bidding option, please try again later."),
                          dismissButton: .default(Text("OK"))
                    )
                })
            .disabled(editSuccess)
        }
    }
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
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
        
        ProjectDetailView(project: project, bidable: project.bidable)
    }
}
