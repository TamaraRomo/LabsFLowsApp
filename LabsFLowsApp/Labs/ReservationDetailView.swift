//
//  ReservationDetailView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 19/06/24.
//

import SwiftUI

struct ReservationDetailView: View {
    let reservation: Reservation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detalles de la Reservación")
                .font(.title2)
                .fontWeight(.bold)

            Text("Nombre de la práctica: \(reservation.practice)")
            Text("Laboratorio: \(reservation.laboratory)")
            Text("Fecha: \(formattedDate(reservation.date))")
            Text("Hora: \(reservation.time)")
            Text("Duración: \(reservation.duration) horas")
            Text("Hora de finalización: \(reservation.endTime)")
            Text("Programa educativo: \(reservation.educationalProgram)")
            Text("Unidad de aprendizaje: \(reservation.learningUnit)")

            Spacer()
        }
        .padding()
    }

    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

