//
//  Extra.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/8/24.
//

import Foundation
import SwiftUI

extension String: Identifiable {
    public var id: UUID {
        UUID()
    }
}

struct MyDisclosureStyle: DisclosureGroupStyle {
    @State private var height: CGFloat = 0
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation() {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(configuration.isExpanded ? Angle.degrees(90) : .zero, anchor: .center)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
//            if configuration.isExpanded {
//                configuration.content
//                    .offset(CGSize(width: 0, height: configuration.isExpanded ? 0 : -height))
//            }
            
            configuration.content
                .offset(CGSize(width: 0, height: configuration.isExpanded ? 0 : -height))
                .hidden(!configuration.isExpanded)
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        height = proxy.size.height
                    }
            }
        )
    }
}

LazyVStack {
    DisclosureGroup("My Accounts", isExpanded: $isExpanded) {
        ForEach(testData, id: \.self) { data in
            MyCustomRowView(data: data)
                .contentShape(Rectangle())
                .onDrag {
                    selection = data
                    return NSItemProvider(object: data as NSString)
                } preview: {
                    Color.clear
                }
            
                .background(data == selection ? .gray.opacity(0.2) : .clear.opacity(1))
            //.opacity(data == selection ? 0 : 1)
                .onDrop(of: [.text], delegate: StringDropDelegate(account: data,
                                                                  accounts: $testData,
                                                                  draggedAccount: $selection,   hidePreview: $hidePreview))
            
                .onTapGesture {
                    selection = data
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
        }
        
    }
    .disclosureGroupStyle(MyDisclosureStyle())


    // Testing
    @State private var testData: [String] = ["Item 0", "Item 1", "Item 2", "Item 3","Item 4", "Item 5", "Item 6", "Item 7"]
    @State private var selection: String?
    @State private var hidePreview: Bool = true
    
    var transaction: Transaction
    
    struct MyCustomRowView: View {
        var data: String
        
        var body: some View {
            HStack {
                Text(data)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(13)
        }
    }
    
    struct MyCustomRowPreview: View {
        var data: String
        var hide: Bool
        
        
        var body: some View {
            HStack {
                Text(data)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            
        }
    }
    @State private var isExpanded: Bool = true
