//
// CategoryListView.swift
// Aspire Budgeting
//

import SwiftUI

struct CategoryListView: View {
  let categories: [DashboardCategory]
  let tintColor: Color

  var body: some View {
    List {
      ForEach(categories, id: \.self) { category in
        CategoryView(category: category, tintColor: tintColor)
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
      }
    }
  }
}

struct CategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryListView(categories: MockProvider.cardViewItems3[0].categories,
                     tintColor: .materialBrown800)
  }
}
