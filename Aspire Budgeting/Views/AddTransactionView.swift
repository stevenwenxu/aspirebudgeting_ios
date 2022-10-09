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
  @State private var amountColor: Color = .expenseRed

  @State private var transaction: Transaction

  @State private var selectedPayee = ""
  @State private var customPayee = ""

  @State private var submittingInProgress = false
  @State private var showAlert = false
  @State private var alertText = ""

  @State private var payeeSearchText = ""

  @FocusState private var focusedField: Field?

  @Environment(\.dismiss) private var dismiss

  init(viewModel: AddTransactionViewModel, transaction: Transaction? = nil) {
    self.viewModel = viewModel
    self._transaction = State(initialValue: transaction ?? Transaction(amount: "", memo: "", date: Date(), account: "", category: "", transactionType: .outflow, approvalType: .pending, payee: "", rowNum: nil))
    self._selectedPayee = State(initialValue: transaction?.payee ?? "")
  }

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
      Picker("Transaction type", selection: $transaction.transactionType) {
        Text("Inflow").tag(TransactionType.inflow)
        Text("Outflow").tag(TransactionType.outflow)
      }
      .pickerStyle(.segmented)
      .onChange(of: transaction.transactionType) { newVal in
        DispatchQueue.main.async {
          focusedField = nil
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
        value: Binding(get: {
          return transaction.amount.isEmpty ? nil : Double(transaction.amount)
        }, set: { newVal in
          transaction.amount = newVal == nil ? "" : String(newVal!)
        }),
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
              transaction.payee = selectedPayee

              // autofill recent category and account if they're empty
              if transaction.category.isEmpty, let recentCategory = PayeeStorage.recentCategory(for: selectedPayee) {
                transaction.category = recentCategory
              }
              if transaction.account.isEmpty, let recentAccount = PayeeStorage.recentAccount(for: selectedPayee) {
                transaction.account = recentAccount
              }
            }
          }
        }

        if selectedPayee.isEmpty {
          TextField("New Payee", text: $customPayee)
            .focused($focusedField, equals: .customPayee)
            .onChange(of: customPayee) { newValue in
              DispatchQueue.main.async {
                transaction.payee = newValue
              }
            }
        }

        Picker("Category", selection: $transaction.category) {
          ForEach(sortedCategories, id: \.self) {
            Text($0)
          }
        }
        .onChange(of: transaction.category) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }

        Picker("Account", selection: $transaction.account) {
          ForEach(sortedAccounts, id: \.self) {
            Text($0)
          }
        }
        .onChange(of: transaction.account) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }
      }

      DatePicker("Date", selection: $transaction.date, displayedComponents: .date)

      Section {
        Toggle(isOn: Binding(get: {
          transaction.approvalType == .pending
        }, set: { newVal in
          transaction.approvalType = newVal ? .pending : .approved
        })) {
          Text("Pending")
        }
        .onChange(of: transaction.approvalType) { _ in
          DispatchQueue.main.async {
            focusedField = nil
          }
        }

        TextField("Memo", text: $transaction.memo)
          .focused($focusedField, equals: .memo)
      }

      Section {
        Button("Add Transaction") {
          submittingInProgress = true

          PayeeStorage.set(recentCategory: transaction.category, for: transaction.payee)
          PayeeStorage.set(recentAccount: transaction.account, for: transaction.payee)

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
        .disabled(submittingInProgress || transaction.invalid)
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
