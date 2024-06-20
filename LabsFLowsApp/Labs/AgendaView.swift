//
//  AgendaView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 19/06/24.
//

import SwiftUI

struct AgendaView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var reservations: [ReservationWithNames] = []
    @State private var selectedReservation: ReservationWithNames?

    var body: some View {
        VStack {
            Text("Reservas de laboratorios")
                .font(.largeTitle)
                .padding()

            List(reservations) { reservation in
                VStack(alignment: .leading) {
                    Text("Práctica: \(reservation.reservation.practice)")
                    Text("Laboratorio: \(reservation.laboratoryName)")
                    Text("Fecha: \(reservation.reservation.date, formatter: DateFormatter.shortDate)")
                    Text("Hora: \(reservation.reservation.time)")
                }
                .onTapGesture {
                    selectedReservation = reservation
                }
            }

            if let reservation = selectedReservation {
                VStack {
                    Text("Detalles de la reservación")
                        .font(.headline)
                    Text("Práctica: \(reservation.reservation.practice)")
                    Text("Laboratorio: \(reservation.laboratoryName)")
                    Text("Fecha: \(reservation.reservation.date, formatter: DateFormatter.shortDate)")
                    Text("Hora: \(reservation.reservation.time)")
                    Text("Duración: \(reservation.reservation.duration) horas")
                    Text("Programa educativo: \(reservation.educationalProgramName)")
                    Text("Unidad de aprendizaje: \(reservation.learningUnitName)")
                    Text("Usuario: \(reservation.reservation.userId)")
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await loadReservations()
            }
        }
    }

    func loadReservations() async {
        do {
            let fetchedReservations = try await viewModel.fetchReservations(for: viewModel.currentUser?.id ?? "")
            reservations = await mapReservationsWithNames(reservations: fetchedReservations)
        } catch {
            print("Error loading reservations: \(error.localizedDescription)")
        }
    }

    func mapReservationsWithNames(reservations: [Reservation]) async -> [ReservationWithNames] {
        var reservationsWithNames: [ReservationWithNames] = []
        for reservation in reservations {
            let laboratoryName = await viewModel.getLaboratoryName(by: reservation.laboratory)
            let educationalProgramName = await viewModel.getEducationalProgramName(by: reservation.educationalProgram)
            let learningUnitName = await viewModel.getLearningUnitName(by: reservation.learningUnit)
            let reservationWithName = ReservationWithNames(reservation: reservation, laboratoryName: laboratoryName, educationalProgramName: educationalProgramName, learningUnitName: learningUnitName)
            reservationsWithNames.append(reservationWithName)
        }
        return reservationsWithNames
    }
}

struct AgendaView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaView()
            .environmentObject(AuthViewModel())
    }
}

struct ReservationWithNames: Identifiable {
    let id = UUID()
    let reservation: Reservation
    let laboratoryName: String
    let educationalProgramName: String
    let learningUnitName: String
    
    init(reservation: Reservation, laboratoryName: String, educationalProgramName: String, learningUnitName: String) {
        self.reservation = reservation
        self.laboratoryName = laboratoryName
        self.educationalProgramName = educationalProgramName
        self.learningUnitName = learningUnitName
    }
}

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}



