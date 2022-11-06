//
//  MockProvider.swift
//  Aspire Budgeting
//

import Foundation

enum MockProvider {
  static var cardViewItems3: [DashboardCardView.DashboardCardItem] {
    var cardViewItems = [DashboardCardView.DashboardCardItem]()
    cardViewItems.append(.init(title: "Credit Card Payments",
                               availableTotal: AspireNumber(stringValue: "$0"),
                               budgetedTotal: AspireNumber(stringValue: "$1000"),
                               spentTotal: AspireNumber(stringValue: "$50"),
                               progressFactor: 0.25,
                               categories: [
                                DashboardCategory(row: ["",
                                               "",
                                               "Dummy Category",
                                               "$30",
                                               "b",
                                               "c",
                                               "20",
                                               "e",
                                               "f",
                                               "15",
                                ]),
                               ]))

    cardViewItems.append(.init(title: "Fixed Expenses",
                               availableTotal: AspireNumber(stringValue: "$0"),
                               budgetedTotal: AspireNumber(stringValue: "$2500"),
                               spentTotal: AspireNumber(stringValue: "$50"),
                               progressFactor: 0.5,
                               categories: [
                                DashboardCategory(row: ["", "", "", "", "", "", "", "", "", ""]), ]))

    cardViewItems.append(.init(title: "Savings",
                               availableTotal: AspireNumber(stringValue: "$0"),
                               budgetedTotal: AspireNumber(stringValue: "$10000"),
                               spentTotal: AspireNumber(stringValue: "$50"),
                               progressFactor: 0.7,
                               categories: [
                                DashboardCategory(row: ["", "", "", "", "", "", "", "", "", ""]), ]))

    return cardViewItems
  }

  static var dashboard: Dashboard {
    var sampleData = [[String]]()
    sampleData.append(["✦", "", "C1", "", "", "", "", "", "", ""])
    sampleData.append(["✧", "", "C1R1", "$10", "", "", "$5", "", "", "$15"])
    sampleData.append(["✧", "", "C1R2", "$10,000", "", "", "$5.09", "", "", "$15,700"])
    sampleData.append(["✦", "", "C2", "", "", "", "", "", "", ""])
    sampleData.append(["✧", "", "C2R1", "-$10", "", "", "$5.00", "", "", "$15"])
    sampleData.append(["✧", "", "C2R2", "$10,000.67", "", "", "$5.08", "", "", "$15,700"])
    return Dashboard(rows: sampleData)
  }

  static var cardViewItems2: [DashboardCardView.DashboardCardItem] {
    [
      .init(
        title: "C1",
        availableTotal: .init(stringValue: "$10,010.00"),
        budgetedTotal: .init(stringValue: "$15,715.00"),
        spentTotal: .init(stringValue: "$10.09"),
        progressFactor: 0.6369710467706015,
        categories: [
          .init(row: ["✧", "", "C1R1", "$10", "", "", "$5", "", "", "$15"]),
          .init(row: ["✧", "", "C1R2", "$10,000", "", "", "$5.09", "", "", "$15,700"]),
        ]
      ),
      .init(
        title: "C2",
        availableTotal: .init(stringValue: "$9,990.67"),
        budgetedTotal: .init(stringValue: "$15,715.00"),
        spentTotal: .init(stringValue: "$10.08"),
        progressFactor: 0.635741011772192,
        categories: [
          .init(row: ["✧", "", "C2R1", "-$10", "", "", "$5.00", "", "", "$15"]),
          .init(row: ["✧", "", "C2R2", "$10,000.67", "", "", "$5.08", "", "", "$15,700"]),
        ]
      ),
    ]
  }

  static var accountBalances: AccountBalances {
    AccountBalances(rows: [
      ["Account 1", "$1234"],
      ["Additional text 1"],
      ["Account 2", "$234"],
      ["Additional text 2"],
    ])
  }

  static var transactions: Transactions {
    Transactions(rows: [
      ["11/11/2050", "S: Tangerine Savings", "Payment: Amex Cobalt", "↕️ Account Transfer", "some notes", "$631.84", "", "🅿️"],
      ["11/11/2050", "Amex Cobalt", "Transfer: S: Tangerine Savings", "↕️ Account Transfer", "", "", "$631.84", "🅿️"],
      ["11/8/2012", "S: Tangerine Savings", "Payment: S: Tangerine Mastercard", "↕️ Account Transfer", "", "$144.38", "", "🅿️"],
      ["11/8/2012", "S: Tangerine Mastercard", "Transfer: S: Tangerine Savings", "↕️ Account Transfer", "", "", "$144.38", "🅿️"]
    ])
  }

  static var addTransactionMetadata: AddTransactionMetadata {
    AddTransactionMetadata(rowsList: [
      ["Category 1", "Category 2", "Category 3"],
      ["Account 1", "Account 2", "Account 3"],
      ["Payee 1", "Payee 2", "Payee 3"]
    ])
  }
}
