//
//  ProjectViewModel.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/19/23.
//

import Foundation

class ProjectViewModel: ObservableObject{
    
    @Published var projects: [Project] = []
    @Published var itemToDelete: Project?
    @Published var itemToEdit: Project?
    
    func fetchProjects(){
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/listmyprojects") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let decodedData = try decoder.decode([Project].self, from: data)
                    DispatchQueue.main.async {
                        self.projects = decodedData
                    }
                } catch {
                    print("Error decoding my project data:", error)
                }
            }
        }.resume()
    }
    
    func createNewProject(name: String, description: String, trade: String, location: String, start_date: Date, bidable: Bool, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/addproject") else {
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: start_date)
        
        let json: [String: Any] = [
            "name": name,
            "description": description,
            "trade": trade,
            "location": location,
            "bidable": bidable,
            "start_date": dateString
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard let _ = data,
                  let httpResponse = response as? HTTPURLResponse,
                  error == nil,
                  httpResponse.statusCode == 201 else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
    
    func deleteProjectServer(project_id: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/deleteproject/\(String(describing: project_id))") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) {data, response, error in
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
    
    func updateProject(project_id: String, name: String, description: String, trade: String, location: String, start_date: Date, bidable: Bool, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?.id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/editproject/\(project_id)") else {
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: start_date)
        
        let json: [String: Any] = [
            "name": name,
            "description": description,
            "trade": trade,
            "location": location,
            "bidable": bidable,
            "start_date": dateString
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {data, response, error in
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
