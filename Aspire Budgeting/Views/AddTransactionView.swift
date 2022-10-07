//
//  AddTransactionView.swift
//  Aspire Budgeting
//

import SwiftUI

struct AddTransactionView: View {
  enum Field {
    case amount
    case customPayee
    case memo
  }

  let viewModel: AddTransactionViewModel

  @State private var amount: Double?
  @State private var amountColor: UIColor = .red

  @State private var memoString = ""

  @State private var selectedDate = Date()

  @State private var selectedCategory = ""
  @State private var selectedAccount = ""
  @State private var selectedPayee = ""
  @State private var customPayee = ""

  @State private var transactionType = TransactionType.outflow
  @State private var pending = true

  @State private var submittingInProgress = false
  @State private var showAlert = false
  @State private var alertText = ""

  @State private var payeeSearchText = ""

  @FocusState private var focusedField: Field?

  @Environment(\.dismiss) private var dismiss

  var filteredPayees: [String] {
    let payees = viewModel.dataProvider?.payees ?? []
    let searchTerm = payeeSearchText.lowercased()
    return searchTerm.isEmpty ? payees : payees.filter { $0.lowercased().contains(searchTerm) }
  }

  var sortedCategories: [String] {
    let unsorted = viewModel.dataProvider?.transactionCategories ?? []
    return selectedPayee.isEmpty ? unsorted : PayeeStorage.orderedCategories(for: selectedPayee, unorderedCategories: unsorted)
  }

  var sortedAccounts: [String] {
    let unsorted = viewModel.dataProvider?.transactionAccounts ?? []
    return selectedPayee.isEmpty ? unsorted : PayeeStorage.orderedAccounts(for: selectedPayee, unorderedAccounts: unsorted)
  }

  var body: some View {
    Form {
      Picker("Transaction type", selection: $transactionType) {
        Text("Inflow").tag(TransactionType.inflow)
        Text("Outflow").tag(TransactionType.outflow)
      }
      .pickerStyle(.segmented)
      .onChange(of: transactionType) { newVal in
        DispatchQueue.main.async {
          focusedField = nil
          switch newVal {
          case .inflow:
            amountColor = .green
          case .outflow:
            amountColor = .red
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
      .focused($focusedField, equals: .amount)

      Section {
        if customPayee.isEmpty {
          Picker("Payee", selection: $selectedPayee) {
            SearchBar(text: $payeeSearchText)
            ForEach(filteredPayees, id: \.self) {
              Text($0)
            }
          }
          .onChange(of: selectedPayee) { _ in
            DispatchQueue.main.async {
              focusedField = nil

              // autofill recent category and account if they're empty
              if selectedCategory.isEmpty, let recentCategory = PayeeStorage.recentCategory(for: selectedPayee) {
                selectedCategory = recentCategory
              }
              if selectedAccount.isEmpty, let recentAccount = PayeeStorage.recentAccount(for: selectedPayee) {
                selectedAccount = recentAccount
              }
            }
          }
        }

        if selectedPayee.isEmpty {
          TextField("New Payee", text: $customPayee)
            .focused($focusedField, equals: .customPayee)
        }

        Picker("Category", selection: $selectedCategory) {
          ForEach(sortedCategories, id: \.self) {
            Text($0)
          }
        }
        .onChange(of: selectedCategory) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }

        Picker("Account", selection: $selectedAccount) {
          ForEach(sortedAccounts, id: \.self) {
            Text($0)
          }
        }
        .onChange(of: selectedAccount) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }
      }

      DatePicker("Date", selection: $selectedDate, displayedComponents: .date)

      Section {
        Toggle(isOn: $pending) {
          Text("Pending")
        }
        .onChange(of: pending) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }

        TextField("Memo", text: $memoString)
          .focused($focusedField, equals: .memo)
      }

      Section {
        Button("Add Transaction") {
          submittingInProgress = true
          let payee = selectedPayee.isEmpty ? customPayee : selectedPayee

          PayeeStorage.set(recentCategory: selectedCategory, for: payee)
          PayeeStorage.set(recentAccount: selectedAccount, for: payee)

          let transaction = Transaction(
            amount: String(amount!),
            memo: memoString,
            date: selectedDate,
            account: selectedAccount,
            category: selectedCategory,
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
        .disabled(submittingInProgress || amount == nil || selectedCategory.isEmpty || selectedAccount.isEmpty || (selectedPayee.isEmpty && customPayee.isEmpty))
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
    .navigationTitle("Add Transaction")
    .background(Color.primaryBackgroundColor)
    .onAppear {
      if viewModel.dataProvider?.transactionAccounts.isEmpty ?? true {
        self.viewModel.refresh()
      }
    }
  }
}
