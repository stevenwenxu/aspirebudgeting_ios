//
// CategoryTransferView.swift
// Aspire Budgeting
//

import SwiftUI

struct CategoryTransferView: View {
  @ObservedObject var viewModel: CategoryTransferViewModel
  
  @State private var amountString = ""
  @State private var memoString = ""
  @State private var fromCategory = TrxCategory(title: "")
  @State private var toCategory = TrxCategory(title: "")
  @State private var showSuccessAlert = false
  @State private var showError = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Form {
      AspireTextField(
        text: $amountString,
        placeHolder: "Amount",
        keyboardType: .decimalPad,
        leftImage: Image.bankNote
      )

      if let categories = self.viewModel.categories?.categories {
        Picker(
          selection: $fromCategory,
          content: {
            ForEach(categories, id: \.self) {
              Text($0.title)
            }
          },
          label: {
            HStack {
              Image.envelope
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("From")
                .font(.nunitoSemiBold(size: 20))
            }
          }
        )

        Picker(
          selection: $toCategory,
          content: {
            ForEach(categories, id: \.self) {
              Text($0.title)
            }
          },
          label: {
            HStack {
              Image.envelope
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
              Text("To")
                .font(.nunitoSemiBold(size: 20))
            }
          }
        )
      }

      AspireTextField(
        text: $memoString,
        placeHolder: "Memo",
        keyboardType: .default,
        leftImage: Image.scribble
      )

      Spacer()

      Button(action: {
        let categorytransfer = CategoryTransfer(
          amount: amountString,
          fromCategory: fromCategory,
          toCategory: toCategory,
          memo: memoString)
        self.viewModel.submit(categoryTransfer: categorytransfer)
      }, label: {
        Text("Transfer")
          .font(.nunitoSemiBold(size: 20))
      })
      .disabled(amountString.isEmpty || fromCategory.title.isEmpty || toCategory.title.isEmpty)
      .interactiveDismissDisabled()
      .alert("Category Transfer submitted", isPresented: $showSuccessAlert, actions: {
        Button("OK") {
          dismiss()
        }
      })
      .alert("Error occured", isPresented: $showError, actions: {
        Button("OK") {
          dismiss()
        }
      }, message: {
        Text(viewModel.error?.localizedDescription ?? "")
      })
    }
    .onAppear { viewModel.getCategories() }
    .onReceive(viewModel.$signal, perform: { signal in
      self.showSuccessAlert = signal != nil
    })
    .onReceive(viewModel.$error, perform: { error in
      self.showError = error != nil

    })
    .navigationTitle("Category Transfer")
  }
}

//struct CategoryTransferView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryTransferView()
//    }
//}
