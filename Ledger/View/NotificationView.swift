//
//  NotificationView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/29/24.
//

import SwiftUI
import Foundation

struct NotificationView: View {
    
    @State private var showNotification = false
    
    @Environment(\.undoManager)
    var undoManger

    var body: some View {
        
        ZStack() {
                Button("Show Notification") {
                    withAnimation(.bouncy) {
                        showNotification.toggle()
                    }
                }
                .padding(.top, 100)
                
                if showNotification {
                    Text("Hello World")
                        .transition(.move(edge: .trailing))
                }
                
                Text("Hello World")
                    .padding()
                    .background(in: RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .containerRelativeFrame([.horizontal, .vertical], alignment: .bottomTrailing)
                    .transition(.identity)
                    .offset(y: showNotification ? 0 : 75)
//                    .onAppear() {
//                        withAnimation(.bouncy) {
//                            showNotification.toggle()
//                        }
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                            withAnimation(.bouncy) {
//                                showNotification.toggle()
//                            }
//                        }
//                    }
            }
            
            
            
            
            

            
            
                    
            
            

            
            
//        }
//        .frame(width: 500, height: 500)
//        .background(.red)
        
    }
}


#Preview {
    NotificationView()
}
