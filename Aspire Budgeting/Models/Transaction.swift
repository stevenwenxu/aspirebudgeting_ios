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

struct Transaction: Hashable, Identifiable {
  var amount: String
  var memo: String
  var date: Date
  var account: String
  var category: String
  var transactionType: TransactionType
  var approvalType: ApprovalType
  var payee: String
  let rowNum: Int?

  var id: String {
    rowNum.flatMap(String.init) ?? UUID().uuidString
  }
}

extension Transaction {
  var param: [String] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"

    let inflow: String
    let outflow: String
    let status: String

    switch transactionType {
    case .inflow:
      inflow = amount
      outflow = ""
    case .outflow:
      inflow = ""
      outflow = amount
    }

    switch approvalType {
    case .pending:
      status = "🅿️"
    case .approved:
      status = "✅"
    case .reconcile:
      status = "*️⃣"
    }

    return [
      dateFormatter.string(from: date),
      account,
      payee,
      category,
      memo,
      outflow,
      inflow,
      status
    ]
  }

  var invalid: Bool {
    return amount.isEmpty || category.isEmpty || account.isEmpty || payee.isEmpty
  }

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

    transactions = rows.enumerated().filter { $1.count == 8 }.compactMap { index, row in
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
                         payee: payee,
                         rowNum: index + 9
      )
    }
  }
}
