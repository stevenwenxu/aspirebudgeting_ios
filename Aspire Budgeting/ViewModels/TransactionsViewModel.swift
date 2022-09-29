//
// TransactionsViewModel.swift
// Aspire Budgeting
//

import Combine
import Foundation
import OrderedCollections

final class TransactionsViewModel: ObservableObject {
  let publisher: AnyPublisher<Transactions, Error>
  let dateFormatter = DateFormatter()
  var cancellables = Set<AnyCancellable>()

  private(set) var transactionsByDate: OrderedDictionary<Date, [Transaction]>?

  @Published private(set) var transactions: Transactions? {
    didSet {
      guard let transactions = transactions?.transactions else { return }
      transactionsByDate = OrderedDictionary(grouping: transactions, by: { $0.date })
    }
  }

  @Published private(set) var error: Error?

  var isLoading: Bool {
    transactions == nil && error == nil
  }

  init(publisher: AnyPublisher<Transactions, Error>) {
    self.publisher = publisher
  }

  func filtered(by filter: String) -> OrderedDictionary<Date, [Transaction]> {
    guard let transactionsByDate = transactionsByDate else {
      return [:]
    }

    if filter.isEmpty {
      return transactionsByDate
    }

    var result = OrderedDictionary<Date, [Transaction]>()
    transactionsByDate.forEach { date, transactions in
      let matchingTransactions = transactions.filter { $0.contains(filter) }
      if !matchingTransactions.isEmpty {
        result[date, default: []].append(contentsOf: matchingTransactions)
      }
    }
    return result
  }

  func formattedDate(for date: Date) -> String {
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    return dateFormatter.string(from: date)
  }

  func refresh() {
    cancellables.removeAll()

    publisher
      .sink { completion in
        switch completion {
        case let .failure(error):
          self.error = error

        case .finished:
          self.error = nil
          Logger.info("Trsansactions fetched.")
        }
      } receiveValue: {
        self.transactions = $0
      }
      .store(in: &cancellables)
  }
}
