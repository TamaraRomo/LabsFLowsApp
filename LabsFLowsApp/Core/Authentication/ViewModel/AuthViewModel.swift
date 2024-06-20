//
//  AuthViewModel.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var reservations: [Reservation] = []
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Hubo una falla iniciar sesión: \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String, employeeNumber: String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullName, employeeNumber: employeeNumber, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        }catch{
            print("DEBUG: Hubo una falla al crear al usuario \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async{
        guard let uid = try? Auth.auth().currentUser?.uid else {return}
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
        self .currentUser = try? snapshot.data(as: User.self)
    }
    
    func fetchLaboratories() async throws -> [Laboratories] {
        let snapshot = try await Firestore.firestore().collection("laboratories").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Laboratories.self)
        }
    }
    
    func fetchEducationalPrograms() async throws -> [EducationalProgram] {
        let snapshot = try await Firestore.firestore().collection("educationalprograms").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: EducationalProgram.self)
        }
    }
    
    func fetchLearningUnit() async throws -> [LearningUnit] {
        let snapshot = try await Firestore.firestore().collection("learningunits").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: LearningUnit.self)
        }
    }
    
    func createReservation(_ reservation: Reservation) async throws {
    do {
        let encodedReservation = try Firestore.Encoder().encode(reservation)
        _ = try await Firestore.firestore().collection("reservations").addDocument(data: encodedReservation)
    } catch {
        throw error
        }
    }

    func fetchReservations(for userId: String) async throws {
        let snapshot = try await Firestore.firestore().collection("reservations")
            .whereField("userId", isEqualTo: userId).getDocuments()
        self.reservations = snapshot.documents.compactMap { document in
            try? document.data(as: Reservation.self)
        }
    }
    
    func checkAvailability(laboratory: String, date: Date, duration: Int, completion: @escaping ([String]) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let availableTimes = ["07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00"]
        
        var unavailableTimes: [String] = []
        
        for reservation in reservations {
            let reservationDateString = dateFormatter.string(from: reservation.date)
            if reservation.laboratory == laboratory && reservationDateString == dateString {
                unavailableTimes.append(reservation.time)
                if let startHour = Int(reservation.time.prefix(2)) {
                    for i in 1..<reservation.duration {
                        let intermediateTime = String(format: "%02d:00", startHour + i)
                        unavailableTimes.append(intermediateTime)
                    }
                }
            }
        }
        
        let filteredTimes = availableTimes.filter { !unavailableTimes.contains($0) }
        
        completion(filteredTimes)
    }


    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

}
