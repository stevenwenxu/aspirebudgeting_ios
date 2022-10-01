//
// LoadingView.swift
// Aspire Budgeting
//

import SwiftUI

struct LoadingView: View {

  @State var isAnimating = false

  let itemsPerRow = 6

  var body: some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: itemsPerRow)) {
        ForEach((0...100), id: \.self) { _ in
          Image.currencySymbols.randomElement()!
            .padding(.vertical)
            .opacity(self.isAnimating ? 0.8 : 0)
            .animation(Animation
              .linear(duration: Double.random(in: 1...2))
              .repeatForever(autoreverses: true)
              .delay(Double.random(in: 0...1.5)))
        }
      }.onAppear {
        isAnimating = true
      }
    }
  }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
      LoadingView()
    }
}
