//
//  DashboardView.swift
//  Aspire Budgeting
//

import Combine
import SwiftUI

struct DashboardView: View {

  @ObservedObject var viewModel: DashboardViewModel
  @State private var searchText = ""
  @State private(set) var showingAlert = false

  var body: some View {
    VStack {
      if self.viewModel.isLoading {
        LoadingView()
      } else {
        DashboardCardsListView(cardViewItems: viewModel.cardViewItems)
          .searchable(text: $searchText) {
            ForEach(viewModel.filteredCategories(filter: searchText), id: \.self) { category in
              CategoryView(category: category, tintColor: .materialGrey800)
            }
         }
      }
    }
    .alert(isPresented: $showingAlert, content: {
      Alert(title: Text("Error Occured"),
            message: Text("\(viewModel.error?.localizedDescription ?? "")"),
            dismissButton: .cancel())
    })
    .onReceive(viewModel.$error, perform: { error in
      self.showingAlert = error != nil
    })
    .background(Color.primaryBackgroundColor)
    .onAppear {
      self.viewModel.refresh()
    }
  }
}

extension View {
  @ViewBuilder
  func ignoreKeyboard() -> some View {
    if #available(iOS 14.0, *) {
      ignoresSafeArea(.keyboard, edges: .all)
    } else {
      self
    }
  }
}

 struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
      DashboardView(
        viewModel: DashboardViewModel(
          publisher: Just(MockProvider.dashboard)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        )
      )
    }
 }
