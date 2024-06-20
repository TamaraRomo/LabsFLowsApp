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
    
    @Published var laboratoryNames: [String: String] = [:]
    @Published var educationalProgramNames: [String: String] = [:]
    @Published var learningUnitNames: [String: String] = [:]
    
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

    func fetchReservations(for userId: String) async throws -> [Reservation] {
        let snapshot = try await Firestore.firestore().collection("reservations")
            .whereField("userId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Reservation.self)
        }
    }
    
    func getLaboratoryName(by id: String) async -> String {
        if let name = laboratoryNames[id] {
            return name
        } else {
            do {
                let document = try await Firestore.firestore().collection("laboratories").document(id).getDocument()
                let name = document.data()?["name"] as? String ?? id
                laboratoryNames[id] = name
                return name
            } catch {
                print("Error fetching laboratory name: \(error.localizedDescription)")
                return id
            }
        }
    }
    
    func getEducationalProgramName(by id: String) async -> String {
        if let name = educationalProgramNames[id] {
            return name
        } else {
            do {
                let document = try await Firestore.firestore().collection("educationalprograms").document(id).getDocument()
                let name = document.data()?["name"] as? String ?? id
                educationalProgramNames[id] = name
                return name
            } catch {
                print("Error fetching educational program name: \(error.localizedDescription)")
                return id
            }
        }
    }
    
    func getLearningUnitName(by id: String) async -> String {
        if let name = learningUnitNames[id] {
            return name
        } else {
            do {
                let document = try await Firestore.firestore().collection("learningunits").document(id).getDocument()
                let name = document.data()?["name"] as? String ?? id
                learningUnitNames[id] = name
                return name
            } catch {
                print("Error fetching learning unit name: \(error.localizedDescription)")
                return id
            }
        }
    }

}
