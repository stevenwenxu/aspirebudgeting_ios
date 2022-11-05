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
  @State private var customPayee = ""

  @State private var transactionType = TransactionType.outflow
  @State private var pending = true

  @State private var submittingInProgress = false
  @State private var showAlert = false
  @State private var alertText = ""

  @State private var payeeSearchText = ""

  @Environment(\.dismiss) private var dismiss

  var filteredPayees: [String] {
    let payees = viewModel.dataProvider?.payees ?? []
    let searchTerm = payeeSearchText.lowercased()
    return searchTerm.isEmpty ? payees : payees.filter { $0.lowercased().contains(searchTerm) }
  }

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
        }

        Section {
          if customPayee.isEmpty {
            NavigationLink {
              List(filteredPayees, id: \.self, selection: $selectedPayee) {
                Text($0)
              }
              .searchable(text: $payeeSearchText, placement: .navigationBarDrawer(displayMode: .always))
            } label: {
              HStack {
                Text("Select payee")
                if let payee = selectedPayee {
                  Spacer()
                  Text(payee)
                }
              }
            }
            .onChange(of: selectedPayee) { _ in
              DispatchQueue.main.async {
                // autofill recent category and account if they're empty
                if selectedCategory == nil, let payee = selectedPayee, let recentCategory = PayeeStorage.recentCategory(for: payee) {
                  selectedCategory = recentCategory
                }
                if selectedAccount == nil, let payee = selectedPayee, let recentAccount = PayeeStorage.recentAccount(for: payee) {
                  selectedAccount = recentAccount
                }
              }
            }
          }

          if selectedPayee == nil {
            TextField("New Payee", text: $customPayee)
          }

          NavigationLink {
            List(sortedCategories, id: \.self, selection: $selectedCategory) {
              Text($0)
            }
          } label: {
            HStack {
              Text("Category")
              if let category = selectedCategory {
                Spacer()
                Text(category)
              }
            }
          }

          NavigationLink {
            List(sortedAccounts, id: \.self, selection: $selectedAccount) {
              Text($0)
            }
          } label: {
            HStack {
              Text("Account")
              if let account = selectedAccount {
                Spacer()
                Text(account)
              }
            }
          }
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
            submittingInProgress = true
            let payee = selectedPayee ?? customPayee

            PayeeStorage.set(recentCategory: selectedCategory!, for: payee)
            PayeeStorage.set(recentAccount: selectedAccount!, for: payee)

            let transaction = Transaction(
              amount: String(amount!),
              memo: memoString,
              date: selectedDate,
              account: selectedAccount!,
              category: selectedCategory!,
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
          .disabled(submittingInProgress || amount == nil || selectedCategory == nil || selectedAccount == nil || (selectedPayee == nil && customPayee.isEmpty))
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
