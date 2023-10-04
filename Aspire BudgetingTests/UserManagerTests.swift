//
//  UserManagerTests.swift
//  Aspire BudgetingTests
//

import Combine
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher
import XCTest

@testable import Aspire_Budgeting

final class UserManagerTests: XCTestCase {
  let mockGIDSignIn = MockGIDSignIn()

  lazy var userManager = GoogleUserManager(
    gidSignInInstance: mockGIDSignIn
  )

  var cancellables = Set<AnyCancellable>()
  override func setUp() {
    super.setUp()
  }

  func testAuthenticateWithService() {
    userManager.authenticate()
    XCTAssertTrue(userManager === mockGIDSignIn.delegate)
    XCTAssertNotNil(mockGIDSignIn.scopes as? [String])
    XCTAssertEqual(
      mockGIDSignIn.scopes as! [String],
      [
        kGTLRAuthScopeDrive,
        kGTLRAuthScopeSheetsDrive,
      ]
    )
    XCTAssertTrue(mockGIDSignIn.restoreCalled)
  }

  func testSignIn() {
    let mockUser = MockUser()

    let exp = XCTestExpectation()
    userManager
      .userPublisher
      .compactMap { $0 }
      .sink { user in
        XCTAssertEqual(user.name, mockUser.profile.name)
        exp.fulfill()
      }
      .store(in: &cancellables)

    userManager.sign(nil, didSignInFor: mockUser, withError: nil)
    wait(for: [exp], timeout: 1)
  }

  func testSignOut() {
    let exp = XCTestExpectation()
    userManager
      .userPublisher
      .sink { user in
        XCTAssertNil(user)
        exp.fulfill()
      }
      .store(in: &cancellables)

    userManager.signOut()
    XCTAssertTrue(mockGIDSignIn.signOutCalled)

    wait(for: [exp], timeout: 1)
  }
}
