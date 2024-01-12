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
    @Published var reviews: [Review] = []
    
    func fetchContractors() {
        fetchMyContractors()
        fetchAllContractors()
    }
    
    private func fetchMyContractors(){
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
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
                            print("Error decoding all contractors data:", error)
                        }
                    }
                }.resume()
    }
    
    func fetchReviews(id: String){
        guard let url = URL(string: "http://localhost:8000/listcontractorsreviews/\(id)") else {
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .formatted(dateFormatter)
                            
                            let decodedData = try decoder.decode([Review].self, from: data)
                            DispatchQueue.main.async {
                                self.reviews = decodedData
                            }
                        } catch {
                            print("Error decoding all reviews data:", error)
                        }
                    }
                }.resume()
    }
    
    func verifyContractorsLicense(id: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/verifycontractorslicense/\(id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                  let httpResponse = response as? HTTPURLResponse,
                  error == nil,
                  httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
    
    func updateContractorsLicense(id: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/updatecontractorslicense/\(id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                  let httpResponse = response as? HTTPURLResponse,
                  error == nil,
                  httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
}


