//
//  AddTransactionView.swift
//  Aspire Budgeting
//

import SwiftUI

struct AddTransactionView: View {
  let viewModel: AddTransactionViewModel

  @State private var amount: Double?
  @State private var amountColor: Color = .expenseRed

  @State private var memoString = ""

  @State private var selectedDate = Date()

  @State private var selectedCategory: String?
  @State private var selectedAccount: String?
  @State private var selectedPayee: String?

  @State private var transactionType = TransactionType.outflow
  @State private var pending = true

  @State private var submittingInProgress = false
  @State private var showAlert = false
  @State private var alertText = ""

  @State private var payeeSearchText = ""
  @State private var categorySearchText = ""
  @State private var accountSearchText = ""

  @Environment(\.dismiss) private var dismiss

  var sortedCategories: [String] {
    let unsorted = viewModel.dataProvider?.transactionCategories ?? []
    return selectedPayee == nil ? unsorted : PayeeStorage.orderedCategories(for: selectedPayee!, unorderedCategories: unsorted)
  }

  var sortedAccounts: [String] {
    let unsorted = viewModel.dataProvider?.transactionAccounts ?? []
    return selectedPayee == nil ? unsorted : PayeeStorage.orderedAccounts(for: selectedPayee!, unorderedAccounts: unsorted)
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Picker("Transaction type", selection: $transactionType) {
            Text("Inflow").tag(TransactionType.inflow)
            Text("Outflow").tag(TransactionType.outflow)
          }
          .pickerStyle(.segmented)
          .onChange(of: transactionType) { newVal in
            DispatchQueue.main.async {
              switch newVal {
              case .inflow:
                amountColor = .expenseGreen
              case .outflow:
                amountColor = .expenseRed
              }
            }
          }

          CurrencyTextField(
            "Amount",
            value: $amount,
            foregroundColor: $amountColor,
            textAlignment: .center
          )
          .font(.title)
          .padding(.vertical, 4)
        }

        Section {
          ItemSelectionLinkView(
            items: viewModel.dataProvider?.payees ?? [],
            itemName: "Payee",
            enableNewItemCreation: true,
            searchText: $payeeSearchText,
            selectedItem: $selectedPayee
          )
          .onChange(of: selectedPayee) { newVal in
            DispatchQueue.main.async {
              // autofill recent category and account if they're empty
              if selectedCategory == nil,
                let payee = newVal,
                let recentCategory = PayeeStorage.recentCategory(for: payee) {
                selectedCategory = recentCategory
              }
              if selectedAccount == nil,
                let payee = newVal,
                let recentAccount = PayeeStorage.recentAccount(for: payee) {
                selectedAccount = recentAccount
              }
            }
          }

          ItemSelectionLinkView(
            items: sortedCategories,
            itemName: "Category",
            enableNewItemCreation: false,
            searchText: $categorySearchText,
            selectedItem: $selectedCategory
          )
          
          ItemSelectionLinkView(
            items: sortedAccounts,
            itemName: "Account",
            enableNewItemCreation: false,
            searchText: $accountSearchText,
            selectedItem: $selectedAccount
          )
        }

        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)

        Section {
          Toggle(isOn: $pending) {
            Text("Pending")
          }

          TextField("Memo", text: $memoString)
        }

        Section {
          Button("Add Transaction") {
            guard
              let amount = amount,
              let payee = selectedPayee,
              let category = selectedCategory,
              let account = selectedAccount
            else { return }
            
            submittingInProgress = true

            PayeeStorage.set(recentCategory: category, for: payee)
            PayeeStorage.set(recentAccount: account, for: payee)

            let transaction = Transaction(
              amount: String(amount),
              memo: memoString,
              date: selectedDate,
              account: account,
              category: category,
              transactionType: transactionType,
              approvalType: pending ? .pending : .approved,
              payee: payee
            )
            viewModel.dataProvider?.submit(transaction) { result in
              switch result {
              case .success:
                alertText = "Transaction added"
              case .failure(let error):
                alertText = error.localizedDescription
              }
              showAlert = true
              submittingInProgress = false
            }
          }
          .disabled(submittingInProgress || amount == nil || selectedCategory == nil || selectedAccount == nil || selectedPayee == nil)
          .alert(alertText, isPresented: $showAlert, actions: {
            Button("OK") {
              dismiss()
            }
          })

          if submittingInProgress {
            ProgressView()
          }
        }
      }
      .interactiveDismissDisabled()
      .scrollDismissesKeyboard(.interactively)
      .navigationTitle("Add Transaction")
      .background(Color.primaryBackgroundColor)
      .onAppear {
        if viewModel.dataProvider?.transactionAccounts.isEmpty ?? true {
          self.viewModel.refresh()
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
      }
    }
  }
}

struct AddTransactionView_Previews: PreviewProvider {
  static var previews: some View {
    AddTransactionView(viewModel: AddTransactionViewModel(
      result: .success(AddTrxDataProvider(
        metadata: MockProvider.addTransactionMetadata,
        submitAction: { _, _ in }
      )),
      refreshAction: {}
    ))
  }
}
