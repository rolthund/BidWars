//
//  ProjectDetailView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/19/23.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @State var bidable: Bool
    
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
                    Section(footer: Text("Allow your contractors with matching trade to bid on this project ")) {
                        Toggle(isOn: self.$bidable) {
                            Text("Allow Bidding")
                                .fontWeight(.semibold)
                        }
                }
                    .padding(.horizontal)
            }
            .navigationBarTitle("Project Details", displayMode: .inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        
                    }
                }
            }
        }
    }
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(
            project_id: "35463",
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
