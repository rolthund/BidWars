//
//  ContractorDetailView.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/28/23.
//

import SwiftUI

struct ContractorDetailView: View {
    @EnvironmentObject var viewModel: ContractorViewModel
    @State var contractor: Contractor
    
    @State private var isLoading = false
    @State private var showVerifiedAlert = false
    @State private var showFailVerifiedAlert = false
    
    var body: some View {
        GeometryReader{g in
            VStack {
                Image("italy")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .background(Color.yellow)
                    .clipShape(Circle())
                    .padding(.bottom, 10)
                Text(contractor.name)
                    .font(.system(size: 20))
                
                NavigationView{
                    Form {
                        
                        
                        Section(header: Text("License Information")) {
                            
                            HStack{
                                Text("State")
                                Spacer()
                                Text("WA")
                            }
                            
                            HStack{
                                Text("Trade")
                                Spacer()
                                Text(contractor.trade)
                            }
                            
                            HStack {
                                HStack {
                                    if(!contractor.license.isInsuranceExpired){
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.brandPrimary)
                                        
                                        Text("Insured")
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                        
                                        Text("Not Insured")
                                    }
                                }
                                Spacer()
                                HStack {
                                    if(!contractor.license.isLicenseExpired){
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.brandPrimary)
                                        
                                        Text("License valid")
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                        
                                        Text("License expired")
                                    }
                                }
                            }
                            
                            HStack{
                                Text("Date of last verification:")
                                Spacer()
                                if(contractor.license.lastverified == "0001-01-01T00:00:00Z"){
                                    Text("Not verified")
                                } else{
                                    Text(Util.util.formatToSimpleStringDate(contractor.license.lastverified ?? ""))
                                }
                            }
                            
                            
                            Button(action: {
                                isLoading = true
                                viewModel.verifyContractorsLicense(id: contractor.id) { success in
                                    if success{
                                        viewModel.updateContractorsLicense(id: contractor.id) { success in
                                            if success{
                                                showVerifiedAlert = true
                                            }
                                        }
                                    }
                                    else{
                                        showFailVerifiedAlert = true
                                    }
                                    isLoading = false
                                }
                                
                            }
                            ) {
                                Text("Check current license and insuranse")
                            }
                        }
                        
                        
                        Section(header: Text("Contact Information")) {
                            HStack{
                                Text("Email")
                                Spacer()
                                Text(contractor.email)
                            }
                            
                            HStack{
                                Text("Phone number")
                                Spacer()
                                Text(contractor.phone)
                            }
                        }
                        
                        Section(header: Text("Reviews")){
                            ReviewsView(reviews: viewModel.reviews)
                        }
                    }
                    .blur(radius: isLoading ? 3 : 0)
                    .overlay(
                        isLoading ? LoadingIndicatorView() : nil
                    )
                }
            }
        }
        .navigationBarTitle("Contractor Details", displayMode: .inline)
        .onAppear{
            viewModel.fetchReviews(id: contractor.id)
        }
        .alert(isPresented: $showVerifiedAlert){
            Alert(title: Text("License verified!"),
                  message: Text("Contractors license and insurance is up to date!"),
                  dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showFailVerifiedAlert){
            Alert(title: Text("Error!"),
                  message: Text("Could not verify this contractor."),
                  dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct LoadingIndicatorView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2)
            Text("Loading...").padding()
        }
        .frame(width: 150, height: 150)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
struct StarRatingView: View {
    let rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { number in
                Image(systemName: number <= rating ? "star.fill" : "star")
                    .foregroundColor(number <= rating ? .yellow : .gray)
            }
        }
    }
}

struct ReviewRowView: View {
    let review: Review
    @State private var builderName: String = "Loading..."
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(builderName)
                    .onAppear {
                        loadReviewAuthors()
                    }
                    .fontWeight(.bold)
                Spacer()
                Text(review.date, formatter: Util.util.dateFormatter)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            StarRatingView(rating: review.rating)

            Text(review.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    func loadReviewAuthors() {
        NetworkManager.shared.getBuilderByID(builder_id: review.builder_id) {builder, error in
            if let builder = builder {
                DispatchQueue.main.async {
                    self.builderName = builder.name
                }
            } else {
                DispatchQueue.main.async {
                    self.builderName = "Error loading"
                }
            }
        }
    }
}

struct ReviewsView: View {
    let reviews: [Review] 

    var body: some View {
        List(reviews) { review in
            ReviewRowView(review: review)
        }
    }
}
    

struct ContractorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let contractor = Contractor(
            id: "12345",
            name: "Alex Doe",
            trade: "Plumbing",
            avr_rating: 4.5,
            email: "john@example.com",
            phone: "555-555-5555",
            reviews: [],
            license: License(UBI_number: "Asd", license_number: "S", insurance: "ASd", bond: "AS", isInsuranceExpired: false, isLicenseExpired: false, lastverified: "0001-01-01T00:00:00Z")
        )

        NavigationView {
            ContractorDetailView(contractor: contractor)
                .environmentObject(ContractorViewModel())
        }
    }
}


