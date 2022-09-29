//
//  AddTransactionView.swift
//  Aspire Budgeting
//

import SwiftUI

struct AddTransactionView: View {
  let viewModel: AddTransactionViewModel

  var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }

  @State private var amountString = ""
  @State private var memoString = ""

  @State private var selectedDate = Date()

  @State private var selectedCategory = -1
  @State private var selectedAccount = -1

  @State private var transactionType = TransactionType.outflow
  @State private var approvalType = ApprovalType.pending

  @State private var showAlert = false
  @State private var alertText = ""

  var showAddButton: Bool {
    !amountString.isEmpty &&
      selectedCategory != -1 &&
      selectedAccount != -1
  }

  func getDateString() -> String {
    self.dateFormatter.string(from: self.selectedDate)
  }

  func clearInputs() {
    self.amountString = ""
    self.memoString = ""
  }

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
    NavigationView {
      Form {
        Picker(selection: $transactionType, label: Text("Transaction Type")) {
          Text("Inflow").tag(TransactionType.inflow)
          Text("Outflow").tag(TransactionType.outflow)
        }.pickerStyle(SegmentedPickerStyle())

        AspireTextField(
          text: $amountString,
          placeHolder: "Amount",
          keyboardType: .decimalPad,
          leftImage: Image.bankNote
        )
        
        if let dataProvider = self.viewModel.dataProvider {
          Picker(
            selection: $selectedCategory,
            label: HStack {
              Image.envelope
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("Select Category")
                .font(.nunitoSemiBold(size: 20))
            }
          ) {
            ForEach(dataProvider.transactionCategories, id: \.self) {
              Text($0)
            }.navigationBarTitle(Text("Select Category"))
          }

          Picker(
            selection: $selectedAccount,
            label: HStack {
              Image.creditCard
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("Select Account")
                .font(.nunitoSemiBold(size: 20))
            }
            ) {
              ForEach(dataProvider.transactionAccounts, id: \.self) {
                Text($0)
              }.navigationBarTitle(Text("Select Account"))
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

        Picker(selection: $approvalType, label: Text("Approval Type")) {
          Text("Approved").tag(ApprovalType.approved)
          Text("Pending").tag(ApprovalType.pending)
        }.pickerStyle(SegmentedPickerStyle())

        AspireTextField(
          text: $memoString,
          placeHolder: "Memo",
          keyboardType: .default,
          leftImage: Image.scribble
        )

        if showAddButton {
          Button(action: {
            let transaction = Transaction(
              amount: amountString,
              memo: memoString,
              date: selectedDate,
              account: self.viewModel.dataProvider!
                .transactionAccounts[selectedAccount],
              category: self.viewModel.dataProvider!
                .transactionCategories[selectedCategory],
              transactionType: transactionType,
              approvalType: approvalType,
              payee: "TODO"
            )
            self.viewModel.dataProvider?.submit(transaction, self.callback)
          }, label: {
            Text("Add Transaction")
          })
          .alert(isPresented: $showAlert) {
            Alert(title: Text(alertText))
          }
        }
      }
      .navigationBarTitle(Text("Add Transaction"))
      .background(Color.primaryBackgroundColor)
    }
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
