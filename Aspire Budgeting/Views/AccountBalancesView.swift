//
//  AccountBalancesView.swift
//  Aspire Budgeting
//

import Combine
import SwiftUI

struct AccountBalancesView: View {
  @ObservedObject var viewModel: AccountBalancesViewModel
  @State private(set) var showingAlert = false

  func getColorForNumber(number: AspireNumber) -> Color {
    if number.isNegative {
      return Color(red: 0.784, green: 0.416, blue: 0.412)
    }
    return Color(red: 0.196, green: 0.682, blue: 0.482)
  }

  var body: some View {
    VStack {
      if self.viewModel.isLoading {
        LoadingView()
      } else {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(self.viewModel.accountBalances.accountBalances, id: \.self) { accountBalance in
              BaseCardView(baseColor: .accountBalanceCardColor) {
                VStack {
                  Text(accountBalance.accountName)
                    .foregroundColor(Color.white)
                    .font(.nunitoSemiBold(size: 20))

                  Text(accountBalance.balance.stringValue)
                    .foregroundColor(self.getColorForNumber(number: accountBalance.balance))
                    .font(.nunitoSemiBold(size: 25))

                  Text(accountBalance.additionalText)
                    .foregroundColor(Color.white)
                    .font(.nunitoRegular(size: 12))
                }
              }
            }
          }
        }
      }
    }
    .alert(isPresented: $showingAlert, content: {
      Alert(title: Text("Error Occured"),
            message: Text("\(viewModel.error?.localizedDescription ?? "")"),
            dismissButton: .cancel())
    })
    .onReceive(viewModel.$error, perform: { error in
      self.showingAlert = error != nil
    })
    .background(Color.primaryBackgroundColor)
    .onAppear {
      self.viewModel.refresh()
    }
  }
}

struct AccountBalancesView_Previews: PreviewProvider {
  static var previews: some View {
    AccountBalancesView(viewModel: .init(
      publisher: Just(MockProvider.accountBalances)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    )
    )
  }
}
