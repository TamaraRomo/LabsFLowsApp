//
//  LoginView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
// Navigation Stack

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack{
            VStack{
                // Imagen
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                // Campos
                VStack(spacing: 15){
                    inputView(text: $email,
                              title: "Correo electrónico",
                              placeholder: "correo@ejemplo.mx")
                    .autocapitalization(.none)
                    inputView(text: $password,
                              title: "Contraseña",
                              placeholder: "Ingrese su contraseña",
                              isSecureField: true)
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                // Botón
                
                Button{
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                }label: {
                    HStack{
                        Text("Iniciar sesión")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 70, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top,12)
                Spacer()
                
                // Registro
                NavigationLink{
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                }label:{
                    HStack(spacing: 3){
                        Text("¿Aún no tienes una cuenta?")
                        Text("Regístrate")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
