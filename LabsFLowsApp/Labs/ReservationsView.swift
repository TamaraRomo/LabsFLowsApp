//
//  ReservationsView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 14/06/24.
//

import SwiftUI

struct ReservationsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedLab: String?
    @State private var laboratories: [Laboratories] = []
    @State private var selectedDate = Date()
    @State private var selectedTime: String = "07:00"
    @State private var selectedDuration: Int = 1
    @State private var selectedProgram: String?
    @State private var educationalprograms: [EducationalProgram] = []
    @State private var selectedUnit: String?
    @State private var learningunits: [LearningUnit] = []
    @State private var practiceName: String = ""
    @State private var isCreatingReservation: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let times = Array(7...20).map { String(format: "%02d:00", $0) }
    let durations = [1, 2, 3]

    var body: some View {
        VStack(spacing: 10) {
            Text("Reservar laboratorio")
                .font(.title2)
                .fontWeight(.bold)

            if laboratories.isEmpty {
                ProgressView("Cargando laboratorios...")
                    .onAppear {
                        Task {
                            await loadLaboratories()
                        }
                    }
            } else {
                Form {
                    Section(header: Text("Seleccione un laboratorio")) {
                        Picker("Laboratorio", selection: $selectedLab) {
                            ForEach(laboratories) { lab in
                                Text(lab.name).tag(Optional(lab.id))
                            }
                        }
                    }

                    Section(header: Text("Seleccione una fecha")) {
                        DatePicker("Fecha de inicio", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    Section(header: Text("Seleccione una hora de inicio")) {
                        Picker("Hora de inicio", selection: $selectedTime) {
                            ForEach(times, id: \.self) { time in
                                Text(time).tag(time)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Section(header: Text("Seleccione una duración")) {
                        Picker("Duración (horas)", selection: $selectedDuration) {
                            ForEach(durations, id: \.self) { duration in
                                Text("\(duration) horas").tag(duration)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Seleccione un programa educativo")) {
                        Picker("Programa educativo", selection: $selectedProgram) {
                            ForEach(educationalprograms) { edup in
                                Text(edup.name).tag(Optional(edup.id))
                            }
                        }
                    }

                    Section(header: Text("Seleccione una unidad de aprendizaje")) {
                        Picker("Materia", selection: $selectedUnit) {
                            ForEach(learningunits) { unit in
                                Text(unit.name).tag(Optional(unit.id))
                            }
                        }
                    }

                    Section(header: Text("Nombre de la práctica")) {
                        TextField("Ingrese el nombre", text: $practiceName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }

                    Button(action: {
                        createReservation()
                    }) {
                        HStack {
                            Text("Crear reservación")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .font(.title3)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.vertical, 10)
                .disabled(isCreatingReservation)
                .blur(radius: isCreatingReservation ? 3 : 0)
                .onAppear {
                    Task {
                        await loadEducationalPrograms()
                        await loadLearningUnits()
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Mensaje"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func loadLaboratories() async {
        do {
            laboratories = try await viewModel.fetchLaboratories()
            if let firstLab = laboratories.first {
                selectedLab = firstLab.id
            }
        } catch {
            print("Error al cargar laboratorios: \(error.localizedDescription)")
        }
    }

    func loadEducationalPrograms() async {
        do {
            educationalprograms = try await viewModel.fetchEducationalPrograms()
            if let firstProgram = educationalprograms.first {
                selectedProgram = firstProgram.id
            }
        } catch {
            print("Error al cargar programas educativos: \(error.localizedDescription)")
        }
    }

    func loadLearningUnits() async {
        do {
            learningunits = try await viewModel.fetchLearningUnit()
            if let firstUnit = learningunits.first {
                selectedUnit = firstUnit.id
            }
        } catch {
            print("Error al cargar las unidades de aprendizaje: \(error.localizedDescription)")
        }
    }

    func createReservation() {
        guard let currentUser = viewModel.currentUser else {
            print("Usuario no encontrado")
            return
        }

        isCreatingReservation = true

        let reservation = Reservation(
            laboratory: selectedLab ?? "",
            date: selectedDate,
            time: selectedTime,
            duration: selectedDuration,
            endTime: calculateEndTime(),
            educationalProgram: selectedProgram ?? "",
            learningUnit: selectedUnit ?? "",
            practice: practiceName,
            userId: currentUser.id
        )

        Task {
            do {
                try await viewModel.createReservation(reservation)
                // Limpiar los campos después de crear la reserva si es necesario
                clearFields()
                // Mostrar el mensaje de éxito
                alertMessage = "La reservación se ha creado correctamente."
            } catch {
                alertMessage = "Error al crear la reserva: \(error.localizedDescription)"
            }
            showAlert = true
            isCreatingReservation = false
        }
    }

    func calculateEndTime() -> String {
        // Implementa la lógica para calcular la hora de fin
        // Ejemplo simple: sumar la duración a la hora de inicio
        let startHour = Int(selectedTime.prefix(2)) ?? 0
        let endHour = startHour + selectedDuration
        return String(format: "%02d:00", endHour)
    }

    func clearFields() {
        selectedLab = laboratories.first?.id
        selectedDate = Date()
        selectedTime = "07:00"
        selectedDuration = 1
        selectedProgram = educationalprograms.first?.id
        selectedUnit = learningunits.first?.id
        practiceName = ""
    }
}

struct ReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationsView()
            .environmentObject(AuthViewModel())
    }
}






