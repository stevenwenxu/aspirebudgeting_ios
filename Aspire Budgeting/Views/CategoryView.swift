//
// CategoryView.swift
// Aspire Budgeting
//

import SwiftUI

struct CategoryView: View {
  let category: DashboardCategory
  let tintColor: Color

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(category.categoryName)
          .font(.karlaBold(size: 16))
          .foregroundColor(.primaryTextColor)
        Spacer()
        AspireNumberView(number: category.available)
      }
      HStack {
        Text(getAuxillaryText(spent: category.spent,
                              budgeted: category.budgeted))
        .font(.karlaRegular(size: 14))
        .foregroundColor(.secondaryTextColor)
        Spacer()

        Text("available")
          .font(.karlaRegular(size: 14))
          .foregroundColor(.secondaryTextColor)
      }

      AspireProgressBar(barType: .minimal,
                        shadowColor: .gray,
                        tintColor: tintColor,
                        progressFactor: category.available /| category.monthly)
    }
  }

  private func getAuxillaryText(spent: AspireNumber, budgeted: AspireNumber) -> String {
    "\(spent.stringValue) spent • \(budgeted.stringValue) budgeted"
  }
}
