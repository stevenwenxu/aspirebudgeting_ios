//
//  SignInView.swift
//  Aspire Budgeting
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
  @Environment (\.colorScheme) var colorScheme: ColorScheme

  @ObservedObject var authViewModel: AuthenticationViewModel
  
  var body: some View {
    VStack {
      Text("Aspire Budgeting")
        .font(.nunitoSemiBold(size: 20))
        .foregroundColor(.primaryTextColor)

      Image.circularLogo
        .padding(.top)

      Text("Welcome to Aspire Budgeting")
        .font(.nunitoRegular(size: 16))
        .foregroundColor(.primaryTextColor)
        .padding()

      Text("Take control of your money everywhere you go")
        .lineLimit(2)
        .font(.nunitoRegular(size: 14))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .frame(width: 173)

      Image.diamondSeparator
        .padding()
      
      GoogleSignInButton(
        scheme: colorScheme == .light ? .light : .dark,
        style: .wide,
        action: authViewModel.signIn
      )
        .frame(height: 50)
        .padding()

    }
    .background(Color.primaryBackgroundColor)
  }
}

//struct SignInView_Previews: PreviewProvider {
//  static var previews: some View {
//    Group {
//      SignInView()
//      SignInView().environment(\.colorScheme, .dark)
//    }
//  }
//}
