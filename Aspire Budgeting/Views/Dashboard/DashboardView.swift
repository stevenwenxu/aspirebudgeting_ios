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
  @State private var isDataLoaded = false

  var body: some View {
    DashboardCardsListView(cardViewItems: viewModel.cardViewItems)
      .background(Color.primaryBackgroundColor)
      .navigationTitle("Dashboard")
      .searchable(text: $searchText) {
        ForEach(viewModel.filteredCategories(filter: searchText), id: \.self) { category in
          CategoryView(category: category, tintColor: .materialGrey800)
        }
      }
      .refreshable {
        viewModel.refresh()
      }
      .onAppear {
        if !isDataLoaded {
          viewModel.refresh()
          isDataLoaded = true
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
