//
// TransactionsView.swift
// Aspire Budgeting
//

import SwiftUI

struct TransactionsView: View {

  @ObservedObject var viewModel: TransactionsViewModel
  let editTransactionViewModel: AddTransactionViewModel
  @State private var searchText = ""
  @State private(set) var showingAlert = false
  @State private var selectedTransaction: Transaction?

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
//                  Text("\(transaction.rowNum!)")
                  VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.payee)
                      .font(.nunitoBold(size: 16))
                    Text(transaction.account)
                      .font(.karlaRegular(size: 14))
                    Text(transaction.category)
                      .font(.karlaRegular(size: 14))
                  }
                  Spacer()
                  VStack(alignment: .trailing) {
                    Text(transaction.amount)
                      .font(.nunitoBold(size: 16))
                      .foregroundColor(
                        transaction.transactionType == .inflow ? .expenseGreen : .expenseRed
                      )
                    if !transaction.memo.isEmpty {
                      Text(transaction.memo)
                        .font(.karlaRegular(size: 14))
                    }
                  }
                }
                .onTapGesture {
                  selectedTransaction = transaction
                }
              }
            } header: { Text(viewModel.formattedDate(for: date)) }
          }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .refreshable {
          viewModel.refresh()
        }
        .sheet(item: $selectedTransaction) { transaction in
          AddTransactionView(viewModel: editTransactionViewModel, transaction: transaction)
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
  private var arrowDown: some View {
    Image(systemName: "arrow.down.circle")
      .foregroundColor(.expenseGreen)
  }

  private var arrowUp: some View {
    Image(systemName: "arrow.up.circle")
      .foregroundColor(.expenseRed)
  }

  private func arrowFor(type: TransactionType) -> AnyView {
    switch type {
    case .inflow:
      return AnyView(arrowDown)
    case .outflow:
      return AnyView(arrowUp)
    }
  }
}

// struct TransactionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionsView()
//    }
// }
