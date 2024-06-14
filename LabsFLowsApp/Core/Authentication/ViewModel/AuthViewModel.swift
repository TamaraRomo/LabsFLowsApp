//
//  AuthViewModel.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        userSession = Auth.auth().currentUser
        //fetchUser()
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("Inicio de sesión...")
    }
    
    func createUser(withEmail email: String, password: String, fullName: String, employeeNumber: String) async throws {
        print("Crear usuario")
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
    
    func fetchUser() async {
        // Aquí puedes cargar datos del usuario si es necesario
    }
}


