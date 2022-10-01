//
//  BaseCardView.swift
//  Aspire Budgeting
//

import SwiftUI

struct BaseCardView<Content: View>: View {
  private let cornerRadius: CGFloat = 5

  private var baseColor: Color
  private let content: Content

  init(baseColor: Color,
       @ViewBuilder content: () -> Content) {
    self.baseColor = baseColor
    self.content = content()
  }

  var body: some View {
    content
      .padding(.vertical)
      .frame(maxWidth: .infinity)
      .background(baseColor)
      .cornerRadius(cornerRadius)
      .padding(.horizontal)
  }
}

// MARK: - Previews
struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Group {
        BaseCardView<Color>(baseColor: .materialBlue800
        ) { Color.materialBlue800 }

        BaseCardView<Color>(baseColor: .materialTeal800
        ) { Color.materialTeal800 }
      }
    }
  }
}
