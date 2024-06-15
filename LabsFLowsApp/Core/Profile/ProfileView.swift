//
//  ProfileView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        if let user = viewModel.currentUser{
            List{
                Section{
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Text(user.employeeNumber)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Menú"){
                    Button{
                        print("Reservar...")
                    }label:{
                        SettingsRowView(imageName: "clock",
                                        title: "Reservar laboratorio",
                                        tintColor: Color(.systemGray))
                    }
                    
                    Button{
                        print("Buscando reservas...")
                    }label:{
                        SettingsRowView(imageName: "calendar",
                                        title: "Ver reservas de laboratorio",
                                        tintColor: Color(.systemGray))
                    }
                }
                
                Section("Cuenta"){
                    Button{
                        Task{
                            viewModel.signOut()
                        }
                    }label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Cerrar sesión",
                                        tintColor: Color(.systemGray))
                    }
                    
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
