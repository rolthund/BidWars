//
//  ContractorListView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 2/4/23.
//

import SwiftUI

struct ContractorListView: View {
    
    @EnvironmentObject var viewModel: ContractorViewModel
    
    @State private var searchText = ""
    @State private var showMyContractorsOnly = true
    
    var filteredContractors: [Contractor] {
        var filtered = showMyContractorsOnly ? viewModel.myContractors : viewModel.allContractors
        
        if !searchText.isEmpty {
            filtered = filtered.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $showMyContractorsOnly, label: Text("Contractors")) {
                    Text("All Contractors").tag(false)
                    Text("My Contractors").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List(filteredContractors, id: \.id) { contractor in
                    NavigationLink(destination: ContractorDetailView(contractor: contractor)) {
                        ContractorDescription(contractor: contractor)
                    }
                }
                .onAppear{
                    viewModel.fetchContractors()
                }
                .navigationTitle("Contractors")
                .searchable(text: $searchText)
            }   
        }
    }
}


struct RatingView:View {
    let rating: Double
    
    var body: some View{
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            
            Text(String(format: "%.1f", rating))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

struct ContractorDescription: View {
    let contractor: Contractor
    
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
                        Text(contractor.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    HStack{
                        Text(contractor.trade)
                        Spacer()
                        RatingView(rating: contractor.avr_rating)
                    }
                    
                }
                
                HStack {
                    HStack {
                        let image: String = !contractor.license.isInsuranceExpired ? "checkmark.circle.fill" : "xmark.circle.fill"
                        let color: Color = !contractor.license.isInsuranceExpired ? .brandPrimary : .red
                        Image(systemName: image)
                            .foregroundColor(color)
                        Text("Insured")
                    }
                    Spacer()
                    HStack {
                        let image = !contractor.license.isLicenseExpired ? "checkmark.circle.fill" : "xmark.circle.fill"
                        let color: Color = !contractor.license.isLicenseExpired ? .brandPrimary : .red
                        Image(systemName: image)
                            .foregroundColor(color)
                        Text("License valid")
                    }
                }
            }
        }
    }
    
}

struct ContractorListView_Previews: PreviewProvider {
    static var previews: some View {
        ContractorListView()
            .environmentObject(ContractorViewModel())
    }
}
