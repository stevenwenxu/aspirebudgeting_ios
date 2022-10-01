//
//  DashboardCardsListView.swift
//  Aspire Budgeting
//

import SwiftUI

struct DashboardCardsListView: View {

  let cardViewItems: [DashboardCardView.DashboardCardItem]

  let baseColors: [Color] =
    [.materialRed800,
     .materialPink800,
     .materialPurple800,
     .materialDeepPurple800,
     .materialIndigo800,
     .materialBlue800,
     .materialLightBlue800,
     .materialTeal800,
     .materialGreen800,
     .materialBrown800,
     .materialGrey800,
    ].shuffled()

  var body: some View {
    List {
      ForEach(0..<self.cardViewItems.count, id: \.self) { idx in
        BaseCardView(baseColor: baseColors[idx]) {
          DashboardCardView(cardViewItem: self.cardViewItems[idx],
                            baseColor: baseColors[idx])
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .buttonStyle(.plain)
      }
    }
    .listStyle(.plain)
    .background(Color.primaryBackgroundColor)
  }
}

struct CardListView_Previews: PreviewProvider {
  static var previews: some View {
    DashboardCardsListView(cardViewItems: MockProvider.cardViewItems3)
  }
}
