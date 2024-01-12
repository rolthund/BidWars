//
//  PostListView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/4/23.
//

import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @State private var searchText = ""
    var projects: [Project] {
        return projectViewModel.projects
    }
    
    var filteredProjects: [Project] {
        var filtered = projects
        if !searchText.isEmpty {
            filtered = filtered.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
        return filtered
    }
    
    @State private var isAddProjectFormPresent = false
    @State private var showDeleteAlert = false
    @State private var shouldDelete = false
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(filteredProjects, id: \.id) { project in
                        
                        NavigationLink(destination: ProjectDetailView(project: project, bidable: project.bidable)) {
                            ProjectDescription(project: project)
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .onAppear{
                    projectViewModel.fetchProjects()
                }
                .navigationTitle("Projects")
                .searchable(text: $searchText)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            isAddProjectFormPresent = true
                        }) {
                            VStack{
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.brandPrimary)
                            }
                        })
            }
            .sheet(isPresented: $isAddProjectFormPresent){
                AddProjectView(isSheetPresented: $isAddProjectFormPresent)
            }
            .alert(isPresented: $showDeleteAlert){
                Alert(
                    title: Text("Delete Item"),
                    message: Text("Are you sure you want to delete this item?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let itemToDelete = projectViewModel.itemToDelete {
                            projectViewModel.deleteProjectServer(project_id: itemToDelete.id){success in
                                if success{
                                    withAnimation {
                                        projectViewModel.projects.removeAll { $0.id == itemToDelete.id }
                                    }
                                }
                            }
                            
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        // Identify the item to delete
        guard let index = offsets.first else { return }
        projectViewModel.itemToDelete = projectViewModel.projects[index]
        
        // Show the alert
        showDeleteAlert = true
    }
    
}

struct ProjectDescription: View {
    let project: Project
    
    var body: some View {
        HStack {
            Image("logo_dark")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            VStack {
                VStack{
                    HStack{
                        Text(project.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    HStack{
                        Text(project.trade)
                            .fontWeight(.semibold)
                            .foregroundColor(.brandPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.50)
                        Spacer()
                        Text(project.location)
                    }
                    
                    HStack{
                        Text(Util.util.dateToString(project.start_date))
                        Spacer()
                    }
                    
                }
            }
        }
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView()
            .environmentObject(ProjectViewModel())
    }
}
