//
// SettingsView.swift
// Aspire Budgeting
//

import SwiftUI

struct SettingsView: View {
  let viewModel: SettingsViewModel

  @State private var showShareSheet = false
  @State private var showFileSelector = false
  @State private var budgetUpdateResult: Result<Bool>?

  var body: some View {
    Form {
      Section(footer:
                VStack(alignment: .leading) {
                  Text("Linked Sheet: \(viewModel.fileName)")
                  Text("App Version: \(AspireVersionInfo.version).\(AspireVersionInfo.build)")
                }) {
        Button("Change Sheet") {
          showFileSelector = true
        }
        Button("Export Log File") {
            showShareSheet = true
        }

        Spacer()

        Button("Update budget") {
          viewModel.scriptManager.run(for: viewModel.user, function: "topUpMonthlyBudget", params: nil) { result in
            budgetUpdateResult = result
          }
        }
      }
    }.sheet(isPresented: $showShareSheet) {
      ShareSheet(activityItems: [logURL])
    }
    .sheet(isPresented: $showFileSelector) {
      FileSelectorView(viewModel: viewModel.fileSelectorVM)
    }
    .alert("Update budget", isPresented: Binding(get: {
      budgetUpdateResult != nil
    }, set: { _ in
      budgetUpdateResult = nil
    }), actions: {}, message: {
      switch budgetUpdateResult {
      case .success(let val) where val:
        Text("Success!")
      case .success:
        Text("Script is still going??")
      case .failure(let error):
        Text("Failed to update budget. Error: \(error.localizedDescription)")
      case .none:
        Text("This should never happen")
      }
    })
    .onReceive(
      viewModel
        .fileSelectorVM
        .$aspireSheet
        .compactMap { $0 }) { _ in
      showFileSelector = false
    }
  }
}

// struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
// }
