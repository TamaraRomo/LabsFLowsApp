//
//  User.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let employeeNumber: String
    let email: String
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Carlos Isidro Pacheco Aguilar", employeeNumber: "66186", email: "al066186@uacam.mx")
}
