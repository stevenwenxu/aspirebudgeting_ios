//
//  MockUser.swift
//  Aspire BudgetingTests
//

import Foundation
import GoogleSignIn
import GTMSessionFetcher

final class MockProfile: GIDProfileData {
  override var name: String {
    "First Last"
  }
}

final class MockUser: GIDGoogleUser {
  override var profile: GIDProfileData! {
    MockProfile()
  }
  
  override var fetcherAuthorizer: GTMFetcherAuthorizationProtocol {
    MockAuthorizer()
  }
}
