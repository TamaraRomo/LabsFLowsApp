//
//  inputView.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 12/06/24.
//

import SwiftUI

struct inputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            
            HStack {
                Text(title)
                    .foregroundColor(Color(.darkGray))
                    .fontWeight(.semibold)
                .font(.footnote)
            }
            if isSecureField{
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            }else{
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
        }
        .padding()
        .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 2)
            .foregroundColor(Color(.systemGray)))
    }
}

struct inputView_Previews: PreviewProvider {
    static var previews: some View {
        inputView(text: .constant(""), title: "Correo electrónico", placeholder: "correo@ejemplo.com")
    }
}
