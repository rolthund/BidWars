//
//  Util.swift
//  BidWars
//
//  Created by Vladyslav Fesenko on 11/24/23.
//

import Foundation

class Util{
    static let util = Util()
    
    private var stateArray: [String] = ["AL", "AK", "AZ", "AR", "CA",
                                       "CO", "CT", "DE", "FL", "GA",
                                       "HI", "ID", "IL", "IN", "IA",
                                       "KS", "KY", "LA", "ME", "MD",
                                       "MA", "MI", "MN", "MS", "MO",
                                       "MT", "NE", "NV", "NH", "NJ",
                                       "NM", "NY", "NC", "ND", "OH",
                                       "OK", "OR", "PA", "RI", "SC",
                                       "SD", "TN", "TX", "UT", "VT",
                                       "VA", "WA", "WV", "WI", "WY"]
    
    private var tradeArray:[String] = ["General","Carpentry", "Electrician", "Plumbing", "Masonry", "Roofing",
                                      "HVAC", "Concrete", "Painting", "Flooring","Drywall", "Insulation", "Framing", "Demolition", "Landscaping","Surveying", "Architectural Design", "Engineering", "Welding", "Scaffolding",
                                      "Glazing", "Cabinetmaking","Cabinet Installation", "Steelworking", "Elevator Installation", "Paving",
                                      "Asphalt Work", "Tile Setting", "Solar Installation", "Fire Sprinkler Installation", "Excavation",
                                      "Fence Installation", "Window Installation","Bricklaying", "Stucco", "Waterproofing",
                                      "Siding", "Gutter Installation", "Swimming Pool Installation",
                                      "Land Clearing", "Ductwork Installation", "Septic System Installation", "Carpet Installation",
                                      "Decking", "Patio Installation"]
    
    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func getStates() -> [String]{
        return stateArray
    }
    
    func getTrades() -> [String]{
        return tradeArray
    }
}

