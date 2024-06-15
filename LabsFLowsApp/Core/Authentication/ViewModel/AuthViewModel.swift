//
//  AuthViewModel.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//protocol AuthenticationFormProtocol {
//    var formIsValid: Bool { get }
//}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
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
}
