//
//  UserManager.swift
//  Aspire Budgeting
//

import Combine
import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher

protocol IGIDSignIn: AnyObject {
  func restorePreviousSignIn(completion: ((GIDGoogleUser?, Error?) -> Void)?)
  func signOut()
}

extension GIDSignIn: IGIDSignIn {}

protocol AspireNotificationCenter: AnyObject {
  func post(
    name aName: NSNotification.Name,
    object anObject: Any?,
    userInfo aUserInfo: [AnyHashable: Any]?
  )
}

extension NotificationCenter: AspireNotificationCenter {}

enum UserManagerState {
  case notAuthenticated
  case authenticated(User)
  case error(Error)
}

protocol UserManager {
  var userPublisher: AnyPublisher<User?, Never> { get }
  func restoreLogin()
  func manualLogin()
}

final class GoogleUserManager: NSObject, UserManager {
  private let gidSignInInstance: IGIDSignIn

  private let userSubject = PassthroughSubject<User?, Never>()
  var userPublisher: AnyPublisher<User?, Never> {
    userSubject
      .eraseToAnyPublisher()
  }

  private var presentingViewController: UIViewController! {
    (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window!.rootViewController
  }

  init(gidSignInInstance: IGIDSignIn = GIDSignIn.sharedInstance) {
    self.gidSignInInstance = gidSignInInstance
  }

  func restoreLogin() {
    Logger.info(
      "Attempting to restore previous Google SignIn"
    )
    gidSignInInstance.restorePreviousSignIn { [weak self] user, error in
      self?.didSignIn(user: user, error: error)
    }
  }
  
  func manualLogin() {
    GIDSignIn.sharedInstance.signIn(
      withPresenting: presentingViewController,
      hint: nil,
      additionalScopes: [kGTLRAuthScopeDrive, kGTLRAuthScopeSheetsDrive, kGTLRAuthScopeSheetsSpreadsheets]
    ) { [weak self] result, error in
      self?.didSignIn(user: result?.user, error: error)
    }
  }
  
  private func didSignIn(user: GIDGoogleUser?, error: Error?) {
    if let error = error {
      if (error as NSError).code == GIDSignInError.Code.hasNoAuthInKeychain.rawValue {
        Logger.info(
          "The user has not signed in before or has since signed out. Proceed with normal sign in flow."
        )
      } else {
        Logger.error(
          "A generic error occured. %{public}s",
          context: error.localizedDescription
        )
      }
    } else if let gUser = user {
      Logger.info(
        "User authenticated with Google successfully."
      )

      userSubject.send(User(
        name: gUser.profile?.name ?? "Unknown user",
        authorizer: gUser.fetcherAuthorizer
      ))
    }
  }

  func signOut() {
    gidSignInInstance.signOut()
    Logger.info(
      "Logging out user from Google and locally"
    )
    userSubject.send(nil)
  }
}
