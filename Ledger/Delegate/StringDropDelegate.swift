import SwiftUI
import Foundation

struct StringDropDelegate: DropDelegate {
    
    let account: String
    @Binding var accounts: [String]
    @Binding var draggedAccount: String?
    @Binding var hidePreview: Bool
    
    static var mayEdit = true

    func dropEntered(info: DropInfo) {

        guard let draggedAccount else {
            print("no draggedAccount")
            return
        }
        
        if draggedAccount != account {
            guard let from = accounts.firstIndex(of: draggedAccount) else {
                print("no from")
                return
            }
            guard let to = accounts.firstIndex(of: account) else {
                print("no to")
                return
            }
            
            withAnimation(.smooth(duration: 0.2)) {
                accounts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
            
//            if Self.mayEdit {
//                Self.mayEdit = false
//
//                withAnimation(.smooth(duration: 0.2)) {
//                    accounts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
//                } completion: {
//                    Self.mayEdit = true
//                }
//            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        //print("drop updated")
        return DropProposal(operation: .move)
    }
    
    
    func performDrop(info: DropInfo) -> Bool {
        print("dropped")
        //draggedAccount = nil
        //hidePreview = true
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        print("validating")
        return Self.mayEdit
    }
    
    func dropExited(info: DropInfo) {
        print("DROP EXITED")
    }
    
    
}
