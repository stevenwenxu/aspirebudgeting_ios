//
//  AccountBalancesView.swift
//  Aspire Budgeting
//

import Combine
import SwiftUI

struct AccountBalancesView: View {
  @ObservedObject var viewModel: AccountBalancesViewModel
  @State private(set) var showingAlert = false
  @State private var isDataLoaded = false

  func getColorForNumber(number: AspireNumber) -> Color {
    if number.isNegative {
      return Color(red: 0.784, green: 0.416, blue: 0.412)
    }
    return Color(red: 0.196, green: 0.682, blue: 0.482)
  }

  var body: some View {
    List {
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
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
      }
    }
    .navigationTitle("Accounts")
    .listStyle(.plain)
    .background(Color.primaryBackgroundColor)
    .refreshable {
      viewModel.refresh()
    }
    .onAppear {
      if !isDataLoaded {
        viewModel.refresh()
        isDataLoaded = true
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
