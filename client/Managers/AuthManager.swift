//
//  AuthManager.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/30/23.
//

import Foundation


class AuthManager {
    static let shared = AuthManager()
    
    func signUp(email: String, password: String, name: String, phone: String, completion: @escaping (Bool) -> Void) {
        
        guard let signUpURL = URL(string: "http://localhost:8000/users/signup") else {
            completion(false)
            return
        }
        
        let json: [String: Any] = [
            "email": email,
            "password": password,
            "name": name,
            "phone": phone
            
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let _ = data,
               let httpResponse = response as? HTTPURLResponse,
               error == nil,
               httpResponse.statusCode == 201 {
                //Success
                completion(true)
                
            } else {
                //Fail
                completion(false)
            }
        }.resume()
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
            // Define the API endpoint for login
            guard let loginURL = URL(string: "http://localhost:8000/users/login") else {
                completion(false)
                return
            }
            
            // Create a dictionary to represent the JSON data
            let json: [String: Any] = [
                "email": email,
                "password": password
            ]
            
            // Convert the dictionary to JSON data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: loginURL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                   let httpResponse = response as? HTTPURLResponse,
                   error == nil,
                   httpResponse.statusCode == 302 else {
                    completion(false)
                    return
                }
                
                do {
                    let builder = try JSONDecoder().decode(Builder.self, from: data)
                    if let builderData = try? JSONEncoder().encode(builder) {
                        UserDefaults.standard.set(builderData, forKey: "builder")
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("Error decoding builder data: \(error)")
                    completion(false)
                }
            }.resume()
        }
    
    func logout(){
        UserDefaults.standard.removeObject(forKey: "builder")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}
