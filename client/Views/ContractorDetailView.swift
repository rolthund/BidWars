//
//  ContractorDetailView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/28/23.
//

import SwiftUI

struct ContractorDetailView: View {
    let contractor: Contractor
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(contractor.name)
                    .font(.largeTitle)
                
                Text(contractor.trade)
                    .foregroundColor(.gray)
                    .font(.title)
                
                Text("Average Rating: \(contractor.avr_rating, specifier: "%.1f")")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "envelope")
                        Text(contractor.email)
                    }
                    
                    HStack {
                        Image(systemName: "phone")
                        Text(contractor.phone)
                    }
                }
                
                Text("Reviews:")
                    .font(.title)
                
            
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationBarTitle("Contractor Details", displayMode: .inline)
    }
}

struct ContractorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let contractor = Contractor(
            contractor_id: "12345",
            name: "John Doe",
            trade: "Plumber",
            avr_rating: 4.5,
            email: "john@example.com",
            phone: "555-555-5555",
            reviews: [],  // An array of Review objects
            license: License(UBI_number: "Asd", license_number: "S", insurance: "ASd", bond: "AS", isInsuranceExpired: false, isLicenseExpired: false)
        )

        NavigationView {
            ContractorDetailView(contractor: contractor)
        }
    }
}


