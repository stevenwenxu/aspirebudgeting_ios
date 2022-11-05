//
// PayeeSelectionView.swift
// Aspire Budgeting
//

import SwiftUI

struct PayeeSelectionView: View {
  let payees: [String]
  @Binding var searchText: String
  @Binding var selectedPayee: String?
  
  @Environment(\.dismiss) private var dismiss

  var filteredPayees: [String] {
    let lower = searchText.lowercased()
    return searchText.isEmpty ? payees : payees.filter { $0.lowercased().contains(lower) }
  }
  
  var body: some View {
    List(selection: $selectedPayee) {
      Section {
        ForEach(filteredPayees, id: \.self) { row in
          Text(row)
        }
      }
      
      if !searchText.isEmpty && !filteredPayees.contains(searchText.lowercased()) {
        Section {
          Button("Create new payee: \(searchText)") {
            selectedPayee = searchText
          }
        }
      }
    }
    .onChange(of: selectedPayee) { _ in
      dismiss()
    }
  }
}

struct PayeeSelectionView_Previews: PreviewProvider {
  static var payee: String?
  static var previews: some View {
    NavigationStack {
      PayeeSelectionView(
        payees: MockProvider.addTransactionMetadata.payees,
        searchText: .constant(""),
        selectedPayee: .constant(nil)
      )
      .searchable(text: .constant(""))
    }
  }
}

struct AddNewPayee_Previews: PreviewProvider {
  static var payee: String?
  static var previews: some View {
    NavigationStack {
      PayeeSelectionView(
        payees: MockProvider.addTransactionMetadata.payees,
        searchText: .constant("New Payee"),
        selectedPayee: .constant(nil)
      )
      .searchable(text: .constant("New Payee"))
    }
  }
}
