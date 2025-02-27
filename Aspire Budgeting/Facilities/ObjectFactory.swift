//
//  ObjectFactory.swift
//  Aspire Budgeting
//

import Foundation
import GoogleSignIn

final class ObjectFactory {
  private let credentialsFileName = "credentials"

  lazy var userManager: GoogleUserManager = {
    GoogleUserManager()
  }()

  lazy var driveManager: GoogleDriveManager = {
    let driveManager = GoogleDriveManager()
    return driveManager
  }()

  lazy var sheetsManager: GoogleSheetsManager = {
    let sheetsManager = GoogleSheetsManager()
    return sheetsManager
  }()

  lazy var localAuthorizationManager: LocalAuthorizationManager = {
    let localAuthManager = LocalAuthorizationManager()
    return localAuthManager
  }()

  lazy var stateManager: StateManager = {
    StateManager()
  }()

  lazy var appDefaultsManager: AppDefaultsManager = {
    AppDefaultsManager()
  }()

  lazy var googleValidator: GoogleSheetsValidator = {
    GoogleSheetsValidator()
  }()

  lazy var googleContentManager: GoogleContentManager = {
    GoogleContentManager(fileReader: sheetsManager, fileWriter: sheetsManager)
  }()

  lazy var authenticationManager: AuthenticationManager = {
    AuthenticationManager(userManager: userManager)
  }()

  lazy var scriptManager: GoogleScriptManager = {
    let manager = GoogleScriptManager()
    return manager
  }()

  lazy var appCoordinator: AppCoordinator = {
    AppCoordinator(stateManager: stateManager,
                   localAuthorizer: localAuthorizationManager,
                   appDefaults: appDefaultsManager,
                   remoteFileManager: driveManager,
                   userManager: userManager,
                   fileValidator: googleValidator,
                   contentProvider: googleContentManager,
                   scriptManager: scriptManager
    )
  }()
}
