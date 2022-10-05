//
// SettingsViewModel.swift
// Aspire Budgeting
//

struct SettingsViewModel {
  let fileName: String
  var changeSheet: () -> Void
  var fileSelectorVM: FileSelectorViewModel
  let user: User
  let scriptManager: GoogleScriptManager
}
