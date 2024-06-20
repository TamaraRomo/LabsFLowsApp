//
//  AgendaView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 19/06/24.
//

import SwiftUI

struct AgendaView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var expandedReservationID: String?
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
            Picker(selection: $selectedTabIndex, label: Text("Filtro de reservas")) {
                Text("Pendientes").tag(0)
                Text("Pasadas").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTabIndex) {
                ReservationListView(reservations: filterReservations(.pending))
                    .tabItem {
                        Label("Pendientes", systemImage: "square.and.pencil")
                    }
                    .tag(0)
                
                ReservationListView(reservations: filterReservations(.past))
                    .tabItem {
                        Label("Pasadas", systemImage: "clock")
                    }
                    .tag(1)
            }
            .onAppear {
                Task {
                    do {
                        if let userId = viewModel.currentUser?.id {
                            try await viewModel.fetchReservations(for: userId)
                        }
                    } catch {
                        print("Error al cargar reservaciones: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationTitle("Agenda")
    }
    
    private func filterReservations(_ type: ReservationType) -> [Reservation] {
        let currentDate = Date()
        switch type {
        case .pending:
            return viewModel.reservations.filter { $0.date >= currentDate }
        case .past:
            return viewModel.reservations.filter { $0.date < currentDate }
        }
    }
}

struct AgendaView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaView()
            .environmentObject(AuthViewModel())
    }
}

enum ReservationType {
    case pending
    case past
}

struct ReservationListView: View {
    let reservations: [Reservation]
    @State private var expandedReservationID: String?

    var body: some View {
        List(reservations) { reservation in
            VStack(alignment: .leading) {
                HStack {
                    Text("Práctica: \(reservation.practice)")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            if expandedReservationID == reservation.id {
                                expandedReservationID = nil
                            } else {
                                expandedReservationID = reservation.id
                            }
                        }
                    }) {
                        Image(systemName: expandedReservationID == reservation.id ? "chevron.up" : "chevron.down")
                    }
                }
                
                if expandedReservationID == reservation.id {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Laboratorio: \(reservation.laboratory)")
                        Text("Fecha: \(reservation.date, formatter: dateFormatter)")
                        Text("Hora: \(reservation.time)")
                        Text("Duración: \(reservation.duration) horas")
                        Text("Programa educativo: \(reservation.educationalProgram)")
                        Text("Unidad de aprendizaje: \(reservation.learningUnit)")
                        Text("Fin: \(reservation.endTime)")
                    }
                    .padding(.top, 5)
                }
            }
            .padding(.vertical, 5)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}








