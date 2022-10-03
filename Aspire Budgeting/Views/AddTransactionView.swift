//
//  AddTransactionView.swift
//  Aspire Budgeting
//

import SwiftUI

struct AddTransactionView: View {
  enum Field {
    case amount
    case memo
  }

  let viewModel: AddTransactionViewModel

  @State private var amountString = ""
  @State private var memoString = ""

  @State private var selectedDate = Date()

  @State private var selectedCategory = ""
  @State private var selectedAccount = ""

  @State private var transactionType = TransactionType.outflow
  @State private var approvalType = ApprovalType.pending

  @State private var showAlert = false
  @State private var alertText = ""

  @FocusState private var focusedField: Field?

  func callback(result: Result<Void>) {
    switch result {
    case .success:
      alertText = "Transaction added"
    case .failure(let error):
      alertText = error.localizedDescription
    }
    showAlert = true
  }

  var body: some View {
    Form {
      Picker("Transaction type", selection: $transactionType) {
        Text("Inflow").tag(TransactionType.inflow)
        Text("Outflow").tag(TransactionType.outflow)
      }
      .pickerStyle(.segmented)
      .onChange(of: transactionType) { _ in
        focusedField = nil
      }

      AspireTextField(
        text: $amountString,
        placeHolder: "Amount",
        keyboardType: .decimalPad,
        leftImage: Image.bankNote
      )
      .focused($focusedField, equals: .amount)

      if let dataProvider = self.viewModel.dataProvider {
        Picker(
          selection: $selectedCategory,
          content: {
            ForEach(dataProvider.transactionCategories, id: \.self) {
              Text($0)
            }
          },
          label: {
            HStack {
              Image.envelope
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("Category")
                .font(.nunitoSemiBold(size: 20))
            }
          }
        )
        .onChange(of: selectedCategory) { _ in
          focusedField = nil
        }

        Picker(
          selection: $selectedAccount,
          content: {
            ForEach(dataProvider.transactionAccounts, id: \.self) {
              Text($0)
            }
          },
          label: {
            HStack {
              Image.creditCard
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("Account")
                .font(.nunitoSemiBold(size: 20))
            }
          }
        )
        .onChange(of: selectedAccount) { _ in
          focusedField = nil
        }
      }

      DatePicker(selection: $selectedDate,
                 displayedComponents: .date) {
        HStack {
          Image(systemName: "calendar")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30, alignment: .center)

          Text("Date: ")
            .font(.nunitoSemiBold(size: 20))
        }
      }

      Picker("Approval Type", selection: $approvalType) {
        Text("Approved").tag(ApprovalType.approved)
        Text("Pending").tag(ApprovalType.pending)
      }
      .pickerStyle(.segmented)
      .onChange(of: approvalType) { _ in
        focusedField = nil
      }

      AspireTextField(
        text: $memoString,
        placeHolder: "Memo",
        keyboardType: .default,
        leftImage: Image.scribble
      )
      .focused($focusedField, equals: .memo)

      Spacer()

      Button(action: {
        let transaction = Transaction(
          amount: amountString,
          memo: memoString,
          date: selectedDate,
          account: selectedAccount,
          category: selectedCategory,
          transactionType: transactionType,
          approvalType: approvalType,
          payee: "TODO"
        )
        self.viewModel.dataProvider?.submit(transaction, self.callback)
      }, label: {
        Text("Add Transaction")
          .font(.nunitoSemiBold(size: 20))
      })
      .buttonStyle(.borderless)
      .disabled(amountString.isEmpty || selectedCategory.isEmpty || selectedAccount.isEmpty)
      .alert(isPresented: $showAlert) {
        Alert(title: Text(alertText))
      }
    }
    .interactiveDismissDisabled()
    .navigationTitle("Add Transaction")
    .background(Color.primaryBackgroundColor)
    .onAppear {
      self.viewModel.refresh()
    }
  }
}

// struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
// }
