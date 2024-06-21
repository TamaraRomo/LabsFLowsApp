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
    @State private var availableTimes: [String] = []

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
                                Text(lab.name).tag(Optional(lab.name))
                            }
                        }
                    }

                    Section(header: Text("Seleccione una fecha")) {
                        DatePicker("Fecha de inicio", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: selectedDate, perform: { _ in
                                loadAvailableTimes()
                            })
                    }

                    Section(header: Text("Seleccione una hora de inicio")) {
                        Picker("Hora de inicio", selection: $selectedTime) {
                            ForEach(availableTimes, id: \.self) { time in
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
                                Text(edup.name).tag(Optional(edup.name))
                            }
                        }
                    }

                    Section(header: Text("Seleccione una unidad de aprendizaje")) {
                        Picker("Materia", selection: $selectedUnit) {
                            ForEach(learningunits) { unit in
                                Text(unit.name).tag(Optional(unit.name))
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
                        loadAvailableTimes()
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
                selectedLab = firstLab.name
            }
        } catch {
            print("Error al cargar laboratorios: \(error.localizedDescription)")
        }
    }
    
    func loadAvailableTimes() {
        guard let selectedLab = selectedLab else { return }
        
        viewModel.checkAvailability(laboratory: selectedLab, date: selectedDate, duration: selectedDuration) { times in
            availableTimes = times
            selectedTime = availableTimes.first ?? "07:00"
        }
    }


    func loadEducationalPrograms() async {
        do {
            educationalprograms = try await viewModel.fetchEducationalPrograms()
            if let firstProgram = educationalprograms.first {
                selectedProgram = firstProgram.name
            }
        } catch {
            print("Error al cargar programas educativos: \(error.localizedDescription)")
        }
    }

    func loadLearningUnits() async {
        do {
            learningunits = try await viewModel.fetchLearningUnit()
            if let firstUnit = learningunits.first {
                selectedUnit = firstUnit.name
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
        
        guard let endTime = calculateEndTime() else {
            alertMessage = "La hora de finalización no puede superar las 21:00."
            showAlert = true
            return
        }

        isCreatingReservation = true

        let reservation = Reservation(
            id: String(),
            userId: currentUser.id,
            laboratory: selectedLab ?? "",
            date: selectedDate,
            time: selectedTime,
            duration: selectedDuration,
            endTime: endTime,
            educationalProgram: selectedProgram ?? "",
            learningUnit: selectedUnit ?? "",
            practice: practiceName
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

    func calculateEndTime() -> String? {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "HH:mm"
       guard let startTime = dateFormatter.date(from: selectedTime) else { return nil }
       let calendar = Calendar.current
       guard let endTime = calendar.date(byAdding: .hour, value: selectedDuration, to: startTime) else { return nil }
       
       let endTimeString = dateFormatter.string(from: endTime)
       if endTimeString > "21:00" {
           return nil
       }
       
       return endTimeString
   }

    func clearFields() {
        selectedLab = laboratories.first?.name
        selectedDate = Date()
        selectedTime = "07:00"
        selectedDuration = 1
        selectedProgram = educationalprograms.first?.name
        selectedUnit = learningunits.first?.name
        practiceName = ""
    }
}

struct ReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationsView()
            .environmentObject(AuthViewModel())
    }
}







