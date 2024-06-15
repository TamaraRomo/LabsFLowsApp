//
//  Reservation.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 14/06/24.
//

import Foundation

struct Reservation: Codable {
    let laboratory: String
    let date: Date
    let time: String
    let duration: Int
    let endTime: String
    let educationalProgram: String
    let learningUnit: String
    let practice: String
    let userId: String
}


