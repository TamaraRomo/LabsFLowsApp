//
//  Reservation.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 14/06/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Reservation: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var laboratory: String
    var date: Date
    var time: String
    var duration: Int
    var endTime: String
    var educationalProgram: String
    var learningUnit: String
    var practice: String
}





