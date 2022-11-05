//
//  SignInView.swift
//  Aspire Budgeting
//

import GoogleSignIn

final class AuthenticationViewModel: ObservableObject {
  private let userManager: UserManager
  
  init(userManager: UserManager) {
    self.userManager = userManager
  }

  /// Signs the user in.
  func signIn() {
    userManager.manualLogin()
  }
}
