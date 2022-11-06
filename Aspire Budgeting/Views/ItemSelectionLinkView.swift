//
// ItemSelectionLinkView.swift
// Aspire Budgeting
//

import SwiftUI

struct ItemSelectionLinkView: View {
  let items: [String]
  let itemName: String
  let enableNewItemCreation: Bool

  @Binding var searchText: String
  @Binding var selectedItem: String?

  var body: some View {
    NavigationLink {
      ItemSelectionView(
        items: items,
        itemName: itemName,
        enableNewItemCreation: enableNewItemCreation,
        searchText: $searchText,
        selectedItem: $selectedItem
      )
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    } label: {
      HStack {
        Text(itemName)
        if let item = selectedItem {
          Spacer()
          Text(item)
            .foregroundColor(.secondary)
        }
      }
    }
    .swipeActions(edge: .trailing) {
      Button("Clear") {
        selectedItem = nil
      }
      .tint(.red)
    }
  }
}

struct Unselected_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      Form {
        ItemSelectionLinkView(
          items: ["a", "b", "c"],
          itemName: "Item",
          enableNewItemCreation: false,
          searchText: .constant(""),
          selectedItem: .constant(nil)
        )
      }
    }
  }
}

struct Selected_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      Form {
        ItemSelectionLinkView(
          items: ["apple", "banana", "candy"],
          itemName: "Item",
          enableNewItemCreation: false,
          searchText: .constant(""),
          selectedItem: .constant("banana")
        )
      }
    }
  }
}
