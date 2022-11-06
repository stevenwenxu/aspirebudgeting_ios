//
// TransactionsView.swift
// Aspire Budgeting
//

import SwiftUI
import Combine

struct TransactionsView: View {

  @ObservedObject var viewModel: TransactionsViewModel
  @State private var searchText = ""
  @State private(set) var showingAlert = false

  var body: some View {
    VStack {
      if viewModel.isLoading {
        GeometryReader { geo in
          LoadingView(height: geo.frame(in: .global).size.height)
        }
      } else {
        List {
          let transactionsByDate = viewModel.filtered(by: searchText)
          ForEach(Array(transactionsByDate.keys), id: \.self) { date in
            Section {
              ForEach(transactionsByDate[date]!, id: \.self) { transaction in
                HStack {
                  arrowFor(type: transaction.transactionType)
                  VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.payee)
                      .font(.headline)
                    Text(transaction.account)
                      .font(.subheadline)
                    Text(transaction.category)
                      .font(.subheadline)
                  }
                  Spacer()
                  VStack(alignment: .trailing, spacing: 4) {
                    Text(transaction.amount)
                      .font(.body)
                      .foregroundColor(
                        transaction.transactionType == .inflow ? .expenseGreen : .expenseRed
                      )
                    if !transaction.memo.isEmpty {
                      Text(transaction.memo)
                        .font(.footnote)
                    }
                  }
                }
              }
            } header: { Text(viewModel.formattedDate(for: date)) }
            .listRowBackground(date > Date() ? Color.gray.opacity(0.4) : nil)
          }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .refreshable {
          viewModel.refresh()
        }
      }
    }
    .navigationTitle("Transactions")
    .background(Color.primaryBackgroundColor)
    .onAppear {
      if viewModel.transactions == nil {
        viewModel.refresh()
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

extension TransactionsView {
  private func arrowFor(type: TransactionType) -> some View {
    switch type {
    case .inflow:
      return Image(systemName: "arrow.down.circle")
        .foregroundColor(.expenseGreen)
    case .outflow:
      return Image(systemName: "arrow.up.circle")
        .foregroundColor(.expenseRed)
    }
  }
}

 struct TransactionsView_Previews: PreviewProvider {
   static var previews: some View {
     NavigationStack {
       TransactionsView(viewModel: TransactionsViewModel(
        publisher: Just(MockProvider.transactions)
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
       ))
     }
   }
 }
