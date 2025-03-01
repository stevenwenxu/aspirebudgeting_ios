//
//  AspireMasterView.swift
//  Aspire Budgeting
// swiftlint:disable inclusive_language

import SwiftUI

struct AspireMasterView: View {
  @EnvironmentObject var appCoordinator: AppCoordinator
  @State private var showAddTransactions = false
  @State private var showCategoryTransfer = false
  @State private var currentSelection = 0

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      TabView(selection: $currentSelection) {
        NavigationStack {
          DashboardView(viewModel: appCoordinator.dashboardVM)
            .toolbar {
              ToolbarItem(placement: .navigation) {
                Button {
                  showCategoryTransfer = true
                } label: {
                  Image(systemName: "repeat.circle")
                }
              }
            }
        }
        .tabItem {
          Label("Dashboard", systemImage: "rectangle.grid.1x2")
        }
        .tag(1)
        .sheet(isPresented: $showCategoryTransfer, content: {
          NavigationView {
            CategoryTransferView(viewModel: appCoordinator.categoryTransferViewModel)
              .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                  Button("Cancel", role: .cancel) {
                    showCategoryTransfer = false
                  }
                }
              }
          }
        })

        NavigationStack { AccountBalancesView(viewModel: appCoordinator.accountBalancesVM) }
          .tabItem {
            Label("Accounts", systemImage: "creditcard")
          }
          .tag(2)

        NavigationStack { TransactionsView(viewModel: appCoordinator.transactionsVM) }
          .tabItem {
            Label("Transactions", systemImage: "arrow.up.arrow.down")
          }
          .tag(3)

        SettingsView(viewModel: appCoordinator.settingsVM)
          .tabItem {
            Label("Settings", systemImage: "gear")
          }
          .tag(4)
      }

      ProminentTabBarItemView(systemImageName: "plus") {
        showAddTransactions = true
      }.offset(x: -16, y: -56)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .sheet(
      isPresented: $showAddTransactions,
      content: {
        AddTransactionView(viewModel: self.appCoordinator.addTransactionVM)
      }
    )
  }
}
