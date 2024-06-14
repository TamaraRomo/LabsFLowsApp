//
//  RegistrationView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var employeeNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dissmiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                // Imagen
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 10)
                // Campos
                VStack(spacing: 10){
                    inputView(text: $email,
                              title: "Correo electrónico",
                              placeholder: "correo@uacam.mx")
                    .autocapitalization(.none)
                    
                    inputView(text: $fullName,
                              title: "Nombre completo",
                              placeholder: "Ingrese su nombre completo")
                    
                    inputView(text: $employeeNumber,
                              title: "Número de empleado",
                              placeholder: "Ingrese su número de empleado")
                    
                    inputView(text: $password,
                              title: "Contraseña",
                              placeholder: "Ingrese su contraseña",
                              isSecureField: true)
                    
                    inputView(text: $confirmPassword,
                              title: "Confirmar contraseña",
                              placeholder: "Confirme su contraseña",
                              isSecureField: true)
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                // Botón
                Button{
                    Task{
                        try await viewModel.createUser(withEmail: email,
                                                       password: password,
                                                       fullName: fullName, employeeNumber: employeeNumber)
                    }
                }label: {
                    HStack{
                        Text("Registrarme")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 70, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top,24)
                Spacer()
                
                Button{
                    dissmiss()
                }label: {
                    HStack(spacing: 3){
                        Text("¿Ya tienes una cuenta?")
                        Text("Inicia sesión")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
