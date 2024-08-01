//
//  SidebarView+CreateAccountFlow.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/29/24.
//

import Foundation
import SwiftUI

extension SidebarView {
    struct CreateAccountFlow: View {
        @Environment(ViewController.self)
        private var viewController
        
        @Environment(\.dismiss)
        private var dismiss
        
        @State private var newAccountName: String = ""
        @State private var startingBalance: Double = 0.0
                
        var body: some View {
            VStack {
                TextField("Account Name", text: $newAccountName)
                    .textFieldStyle(.plain)
                    .font(.title2)
                
                HStack {
                    Text("Starting Balance:")
                    
                    TextField("", value: $startingBalance, format: .currency(code: "USD"))
                        .textFieldStyle(.plain)
                        .focusEffectDisabled()
                    
                    Spacer()
                }
                .opacity(startingBalance.isZero ? 0.8 : 1)
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button("Cancel", role: .cancel) {
                        dismiss.callAsFunction()
                    }
                    
                    Button("Create") {
                        _createAccountAndDismiss()
                    }
                    .modifier(VariableButtonStyle(primaryStyle: .automatic,
                                                  secondaryStyle: .borderedProminent,
                                                  presentingPrimary: newAccountName.isEmptyOrWhitespace))
                    .disabled(newAccountName.isEmptyOrWhitespace)
                }
            
            }
            .padding()
            .frame(width: 300, height: 150)
            .onKeyPress(.return) {
                _createAccountAndDismiss()
                return .handled
            }
            
        }
        
        private func _createAccountAndDismiss() {
            guard !newAccountName.isEmptyOrWhitespace else { return }
            
            viewController.createAccount(name: newAccountName.stripped,
                                         startingBalance: startingBalance != 0 ? startingBalance : nil)
            dismiss.callAsFunction()
        }
    }
}

fileprivate struct VariableButtonStyle<PrimaryStyle: PrimitiveButtonStyle, SecondaryStyle: PrimitiveButtonStyle>: ViewModifier {
    
    var primaryStyle: PrimaryStyle
    var secondaryStyle: SecondaryStyle
    
    var presentingPrimary: Bool

    func body(content: Content) -> some View {
        if presentingPrimary {
            content
                .buttonStyle(primaryStyle)
        } else {
            content
                .buttonStyle(secondaryStyle)
        }
    }
}


