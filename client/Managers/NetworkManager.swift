//
//  NetworkManager.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 9/8/23.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func getBuilderFromDefaults() -> Builder? {
        if let savedBuilderData = UserDefaults.standard.data(forKey: "builder"){
            print(String(data: savedBuilderData, encoding: .utf8) ?? "")
            do {
                let savedBuilder = try JSONDecoder().decode(Builder.self, from: savedBuilderData)
                return savedBuilder
            } catch {
                print("Error decoding builder data: \(error)")
            }
            
        } else {
            print("Builder data not found in UserDefaults")
        }
        
        let builder = Builder(
            user_id: "",
            name: "",
            email: "",
            phone: "",
            project: [],
            license: License(UBI_number: "", license_number: "", insurance: "", bond: "", isInsuranceExpired: true, isLicenseExpired: true)
        )
        return builder
    }
    
    func verifyLicense(UBI_number: String, license_number: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?._id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/verifylicense") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let json: [String: Any] = [
            "isInsuranceExpired": false,
            "isLicenseExpired": false,
            "UBI_number": UBI_number,
            "license_number": license_number,
            "insurance": "",
            "bond": ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            completion(false)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
    func updateLicense(UBI_number: String, license_number: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?._id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/updatelicense") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let json: [String: Any] = [
            "isInsuranceExpired": false,
            "isLicenseExpired": false,
            "UBI_number": UBI_number,
            "license_number": license_number,
            "bond": "",
            "insurance": "",
            
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            completion(false)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
    func verifyPhoneNumber(code: String, completion: @escaping (Bool) -> Void) {
        let user_id = NetworkManager.shared.getBuilderFromDefaults()?._id
        guard let url = URL(string: "http://localhost:8000/users/\(String(describing: user_id!))/verifyphone?code=\(code)") else {
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

