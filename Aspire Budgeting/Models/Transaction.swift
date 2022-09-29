//
// Transaction.swift
// Aspire Budgeting
//

import Foundation

extension String {
  func caseInsensitiveCompare(_ other: String) -> Bool {
    self.caseInsensitiveCompare(other) == .orderedSame
  }
}
extension Collection {
  subscript (safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

enum ApprovalType {
  case pending
  case approved
  case reconcile

  static func approvalType(from: String) -> Self {
    switch from {
    case "✅", "🆗":
      return .approved

    case "🅿️", "⏺":
      return .pending

    default:
      return .reconcile
    }
  }
}

enum TransactionType {
  case inflow
  case outflow
}

struct Transaction: Hashable {
  let amount: String
  let memo: String
  let date: Date
  let account: String
  let category: String
  let transactionType: TransactionType
  let approvalType: ApprovalType
  let payee: String
}

extension Transaction {
  func contains(_ text: String) -> Bool {
    self.amount.caseInsensitiveCompare(text) ||
      self.memo.lowercased().contains(text.lowercased()) ||
      self.account.lowercased().contains(text.lowercased()) ||
      self.category.lowercased().contains(text.lowercased()) ||
      self.payee.lowercased().contains(text.lowercased())
  }
}

struct Transactions: ConstructableFromRows {
  let transactions: [Transaction]

  init(rows: [[String]]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"

    transactions = rows.filter { $0.count == 8 }.compactMap { row in
      let date = dateFormatter.date(from: row[0]) ?? Date()
      let account = row[1]
      let payee = row[2]
      let category = row[3]
      let memo = row[4]
      let (amount, transactionType) =
        row[5].isEmpty ? (row[6], TransactionType.inflow) : (row[5], TransactionType.outflow)
      let approvalType = ApprovalType.approvalType(from: row[7])

      if approvalType == .reconcile { return nil }

      return Transaction(amount: amount,
                         memo: memo,
                         date: date,
                         account: account,
                         category: category,
                         transactionType: transactionType,
                         approvalType: approvalType,
                         payee: payee
      )
    }
  }
}
