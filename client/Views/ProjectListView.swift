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
    @State private var isDeleteButtonTapped = false
    @State private var showDeletionError = false
    @State private var projectCreateSuccess = false
    
    var body: some View {
        NavigationView{
                VStack{
                    List{
                        ForEach(filteredProjects.indices, id:\.self) { index in
                           let project = filteredProjects[index]
                        NavigationLink(destination: ProjectDetailView(project: project, bidable: project.bidable)) {
                            ProjectDescription(project: project)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false){
                                    Button {
                                        
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.brandPrimary)
                                    
                                    Button {
                                        isDeleteButtonTapped = true
                                        projectViewModel.deleteProjectServer(project_id: project.project_id){ success in
                                            if success{
                                                projectViewModel.projects.remove(at: index)
                                            } else {
                                                showDeletionError = true
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .onDelete(perform: projectViewModel.deleteProject)
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
                    AddProjectView(isSheetPresented: $isAddProjectFormPresent, isCreatedSuccessfully: $projectCreateSuccess)
                }
                .overlay(
                    EmptyView()
                        .alert(isPresented: $showDeletionError){
                            Alert(title: Text("Deletion Failed"), message: Text("The item could not be deleted at this time. Please check your internet connection and try again."), dismissButton: .default(Text("OK")))
                        }
                )
                .overlay(EmptyView()
                    .alert(isPresented: $isDeleteButtonTapped){
                        Alert(title: Text("Allow contractors to bid?"),
                              message: Text("Do you want your contractors to be able to bid for this project (you can always allow this later)."),
                              primaryButton: .default(Text("Allow"), action: {/*bidable = true;*/ isDeleteButtonTapped = false}),
                              secondaryButton: .default(Text("Don't allow"), action: {/*bidable = false;*/ isDeleteButtonTapped = false})
                        )
                    })
        }
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
