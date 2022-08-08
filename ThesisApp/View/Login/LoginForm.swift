//
//  LoginForm.swift
//  thesis-app
//
//  Created by Lisa Wittmann on 31.07.22.
//

import SwiftUI

struct LoginForm: View {
    
    @StateObject var model = LoginFormModel()
    var switchMode: () -> Void
    
    var body: some View {
        ZStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .offset(y: -120)
                .padding(.bottom, -150)
        }
        
        VStack(spacing: spacingMedium) {
            Text("Anmelden")
                .modifier(FontTitle())
            
            VStack {
                Text("Bitte melde dich an um fortzufahren.").modifier(FontText())
                Button(action: switchMode) {
                    Text("Noch kein Konto? Jetzt registrieren").modifier(FontText())
                }
                
            }
            
            Spacer()
            
            VStack(spacing: spacingLarge) {
                InputField(model.mail)
                InputField(model.password)
            }
            
            Spacer()
            
            ButtonIcon(
                "Anmelden",
                icon: "arrow.forward",
                disabled: model.errors,
                action: model.submit
            )
        }
    }
}

struct LoginForm_Previews: PreviewProvider {
    static var previews: some View {
        Page {
            LoginForm(switchMode: {})
        }
    }
}
