//
//  ContentView.swift
//  Aspire Budgeting
//

import Combine
import GoogleSignIn
import SwiftUI

struct ContentView: View {
  @ObservedObject var authenticationManager: AuthenticationManager
  @EnvironmentObject var appCoordinator: AppCoordinator

  var needsLocalAuth: Bool {
    appCoordinator.needsLocalAuth
  }

  var isLoggedOut: Bool {
    authenticationManager.isLoggedOut
  }

  var hasDefaultSheet: Bool {
    appCoordinator.hasDefaultSheet
  }

  var body: some View {
    VStack {
      if isLoggedOut {
        SignInView(authViewModel: authenticationManager.authViewModel)
          .frame(maxHeight: .infinity)
      } else if needsLocalAuth {
        FaceIDView()
      } else if hasDefaultSheet {
        AspireMasterView()
      } else {
        FileSelectorView(viewModel: appCoordinator.fileSelectorVM)
      }
    }.background(Color.primaryBackgroundColor.edgesIgnoringSafeArea(.all))
  }
}

// struct ContentView_Previews: PreviewProvider {
//  static let objectFactory = ObjectFactory()
//    static var previews: some View {
//      ContentView(userManager: objectFactory.userManager,
//                  driveManager: objectFactory.driveManager,
//                  sheetsManager: objectFactory.sheetsManager,
//                  localAuthorizationManager: objectFactory.localAuthorizationManager,
//                  stateManager: objectFactory.stateManager)
//    }
// }
