//
//  Models.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 8/26/23.
//

import Foundation


class Builder: Codable, ObservableObject{
    var id: String
    var name: String
    var email: String
    var phone: String
    var project: [String] = []
    var license: License? = nil
    
    init(id: String, name: String, email: String, phone: String, project: [String], license: License) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.project = project
        self.license = license
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.project = []
        self.license = try container.decodeIfPresent(License.self, forKey: .license)
    }
    
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case name
        case email
        case phone
        case license
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(license, forKey: .license)
    }
    
}

struct Contractor: Codable {
    let id: String
    let name: String
    let trade: String
    let avr_rating: Double
    let email: String
    let phone: String
    let reviews: [Review]
    let license: License
    
    init(id: String, name: String, trade: String, avr_rating: Double, email: String, phone: String, reviews: [Review], license: License) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.trade = trade
        self.avr_rating = avr_rating
        self.reviews = reviews
        self.license = license
    }
    
    enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case trade
            case avr_rating
            case email
            case phone
            case reviews
            case license
        }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name.uppercased(), forKey: .name)
        try container.encode(trade, forKey: .trade)
        try container.encode(avr_rating, forKey: .avr_rating)
        try container.encode(email.lowercased(), forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(reviews, forKey: .reviews)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name).lowercased()
        trade = try container.decode(String.self, forKey: .trade)
        avr_rating = try container.decode(Double.self, forKey: .avr_rating)
        email = try container.decode(String.self, forKey: .email).uppercased()
        phone = try container.decode(String.self, forKey: .phone)
        reviews = try container.decode([Review].self, forKey: .reviews)
        license = try container.decode(License.self, forKey: .license)
    }
    
}


class Review: Codable,Identifiable {

    var id: String
    var builder_id: String
    var contractor_id: String
    var rating: Int
    var description: String
    var date: Date
    
    init(id: String, builder_id: String, contractor_id: String, rating: Int, description: String, date: Date) {
        self.id = id
        self.builder_id = builder_id
        self.contractor_id = contractor_id
        self.rating = rating
        self.description = description
        self.date = date
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.builder_id = try container.decode(String.self, forKey: .builder_id)
        self.contractor_id = try container.decode(String.self, forKey: .contractor_id)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.description = try container.decode(String.self, forKey: .description)
        self.date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(builder_id, forKey: .builder_id)
        try container.encode(contractor_id, forKey: .contractor_id)
        try container.encode(rating, forKey: .rating)
        try container.encode(description, forKey: .description)
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        try container.encode(dateString, forKey: .date)
    }
    
    
    
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case builder_id
        case contractor_id
        case rating
        case description
        case date
    }
}


struct License: Codable{
    let UBI_number: String?
    let license_number: String?
    let insurance: String?
    let bond: String?
    let isInsuranceExpired: Bool
    let isLicenseExpired: Bool
    let lastverified: String?
}

class Project: Codable, ObservableObject{
    var id: String
    var builder_id: String
    var name: String
    var description: String
    var trade: String
    var location: String
    var bidable: Bool
    var start_date: Date
    
    enum CodingKeys: String, CodingKey {
            case id = "_id"
            case builder_id
            case description
            case name
            case trade
            case location
            case bidable
            case start_date
        }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.builder_id = try container.decode(String.self, forKey: .builder_id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.trade = try container.decode(String.self, forKey: .trade)
        self.location = try container.decode(String.self, forKey: .location)
        self.bidable = try container.decode(Bool.self, forKey: .bidable)
        self.start_date = try container.decode(Date.self, forKey: .start_date)
    }
    
    init(id: String, builder_id: String, name: String, description: String, trade: String, location: String, bidable: Bool, start_date: Date){
        self.id = id
        self.builder_id = builder_id
        self.name = name
        self.description = description
        self.trade = trade
        self.location = location
        self.bidable = bidable
        self.start_date = start_date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(name, forKey: .name)
        try container.encode(trade, forKey: .trade)
        try container.encode(location, forKey: .location)
        try container.encode(bidable, forKey: .bidable)
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: start_date)
        
        try container.encode(dateString, forKey: .start_date)
    }
}


