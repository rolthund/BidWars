//
//  Contractors.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/26/23.
//

import Foundation
import Combine


class ContractorViewModel: ObservableObject{
    
    @Published var myContractors: [Contractor] = []
    @Published var allContractors: [Contractor] = []
    
    func fetchContractors() {
        fetchMyContractors()
        fetchAllContractors()
    }
    
    private func fetchMyContractors(){
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?._id
        print(user_id!)
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/listmycontractors") else {
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decodedData = try JSONDecoder().decode([Contractor].self, from: data)
                            DispatchQueue.main.async {
                                self.myContractors = decodedData
                            }
                        } catch {
                            print("Error decoding my contractors data:", error)
                        }
                    }
                }.resume()
    }
    
    private func fetchAllContractors(){
        guard let url = URL(string: "http://localhost:8000/listcontractors") else {
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decodedData = try JSONDecoder().decode([Contractor].self, from: data)
                            DispatchQueue.main.async {
                                self.allContractors = decodedData
                            }
                        } catch {
                            print("Error decoding my contractors data:", error)
                        }
                    }
                }.resume()
    }
}


