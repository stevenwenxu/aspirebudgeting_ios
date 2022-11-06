//
// ItemSelectionView.swift
// Aspire Budgeting
//

import SwiftUI

struct ItemSelectionView: View {
  let items: [String]
  let itemName: String
  let enableNewItemCreation: Bool
  
  @Binding var searchText: String
  @Binding var selectedItem: String?
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dismissSearch) private var dismissSearch

  var filteredItems: [String] {
    let lower = searchText.lowercased()
    return searchText.isEmpty ? items : items.filter { $0.lowercased().contains(lower) }
  }
  
  var body: some View {
    List(selection: $selectedItem) {
      Section {
        ForEach(filteredItems, id: \.self) { row in
          Text(row)
        }
      }
      
      if enableNewItemCreation && !searchText.isEmpty && !filteredItems.contains(searchText.lowercased()) {
        Section {
          Button("Create new \(itemName): \(searchText)") {
            selectedItem = searchText
            dismissSearch()
          }
        }
      }
    }
    .onChange(of: selectedItem) { _ in
      // for some reason, dismissing directly will result in an automatic push later
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        dismiss()
      }
    }
  }
}

struct ItemSelectionView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ItemSelectionView(
        items: ["a", "b", "c"],
        itemName: "choice",
        enableNewItemCreation: false,
        searchText: .constant(""),
        selectedItem: .constant(nil)
      )
      .searchable(text: .constant(""))
    }
  }
}

struct AddItem_Previews: PreviewProvider {
  static var payee: String?
  static var previews: some View {
    NavigationStack {
      ItemSelectionView(
        items: ["a", "b", "c"],
        itemName: "choice",
        enableNewItemCreation: true,
        searchText: .constant("New Item"),
        selectedItem: .constant(nil)
      )
      .searchable(text: .constant("New Item"))
    }
  }
}
