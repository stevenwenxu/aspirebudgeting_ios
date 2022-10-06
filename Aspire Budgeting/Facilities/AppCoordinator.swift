//
// AppCoordinator.swift
// Aspire Budgeting
//

import Foundation
import Combine

final class AppCoordinator: ObservableObject {
  private let stateManager: AppStateManager
  private let localAuthorizer: AppLocalAuthorizer
  private let appDefaults: AppDefaults
  private let remoteFileManager: RemoteFileManager
  private let userManager: UserManager
  private let fileValidator: FileValidator
  private let contentProvider: ContentProvider
  private let scriptManager: GoogleScriptManager

  private var cancellables = Set<AnyCancellable>()

  private(set) var fileSelectorVM: FileSelectorViewModel!
  private(set) var dashboardVM: DashboardViewModel!
  private(set) var accountBalancesVM: AccountBalancesViewModel!
  private(set) var transactionsVM: TransactionsViewModel!
  private(set) var settingsVM: SettingsViewModel!
  private(set) var categoryTransferViewModel: CategoryTransferViewModel!

  private(set) lazy var addTransactionVM: AddTransactionViewModel = {
    AddTransactionViewModel(refreshAction: self.addTransactionRefreshCallback)
  }()

  @Published private(set) var user: User?
  @Published private(set) var selectedSheet: AspireSheet?
  @Published private(set) var isLoading = false

  // TODO: Remove these two
  private var selectedFile: File?
  private var dataLocationMap: [String: String]?

  init(stateManager: AppStateManager,
       localAuthorizer: AppLocalAuthorizer,
       appDefaults: AppDefaults,
       remoteFileManager: RemoteFileManager,
       userManager: UserManager,
       fileValidator: FileValidator,
       contentProvider: ContentProvider,
       scriptManager: GoogleScriptManager
  ) {
    self.stateManager = stateManager
    self.localAuthorizer = localAuthorizer
    self.appDefaults = appDefaults
    self.remoteFileManager = remoteFileManager
    self.userManager = userManager
    self.fileValidator = fileValidator
    self.contentProvider = contentProvider
    self.scriptManager = scriptManager
  }

  private func setupViewModels(for user: User, sheet: AspireSheet) {
    self.dashboardVM =
      DashboardViewModel(
        publisher: self.contentProvider
          .getData(
            for: user,
            from: sheet.file,
            using: sheet.dataMap)
      )

    self.accountBalancesVM =
      AccountBalancesViewModel(
        publisher: self.contentProvider
          .getData(
            for: user,
            from: sheet.file,
            using: sheet.dataMap)
      )

    self.transactionsVM =
      TransactionsViewModel(
        publisher: self.contentProvider
          .getData(
            for: user,
            from: sheet.file,
            using: sheet.dataMap)
      )

    self.settingsVM =
      SettingsViewModel(
        fileName: sheet.file.name,
        changeSheet: {

        },
        fileSelectorVM: fileSelectorVM,
        user: user,
        scriptManager: scriptManager
      )

    categoryTransferViewModel =
      CategoryTransferViewModel(
        categoriesPublisher: contentProvider
          .getData(for: user,
                   from: sheet.file,
                   using: sheet.dataMap),
        submitter: { [unowned self] categoryTransfer in
          self.contentProvider
            .write(data: categoryTransfer, for: user, to: sheet.file, using: sheet.dataMap)
        }
      )
  }

  func start(for user: User) {
    self.user = user
    self.selectedSheet = appDefaults.getDefaultSheet()

    fileSelectorVM = FileSelectorViewModel(
      fileManager: remoteFileManager,
      fileValidator: fileValidator,
      user: user
    )

    fileSelectorVM
      .$aspireSheet
      .compactMap { $0 }
      .sink { [weak self] aspireSheet in
        guard let self = self else { return }
        self.selectedSheet = aspireSheet
        self.appDefaults.addDefault(sheet: aspireSheet)
        self.setupViewModels(for: user, sheet: aspireSheet)
      }
      .store(in: &cancellables)

    if let selectedSheet = self.selectedSheet {
      setupViewModels(for: user, sheet: selectedSheet)
    }

    // TODO: Remove
    stateManager
      .currentState
      .receive(on: DispatchQueue.main)
      .sink {
        self.objectWillChange.send()
        self.handle(state: $0)
      }
      .store(in: &cancellables)
  }

  func pause() {
    self.stateManager.processEvent(event: .enteredBackground)
  }

  func resume() {
    if needsLocalAuth {
//      self.localAuthorizer.authenticateUserLocally {
//        self.stateManager.processEvent(event: .authenticatedLocally(result: $0))
//      }
    }
  }
}

// MARK: - Callbacks
extension AppCoordinator {
  func addTransactionRefreshCallback() {
    self.contentProvider
      .getBatchData(
        for: self.user!,
        from: self.selectedSheet!.file,
        using: self.selectedSheet!.dataMap) { (readResult: Result<AddTransactionMetadata>) in

        let result: Result<AddTrxDataProvider>

        switch readResult {
        case .success(let metadata):
          result = .success(AddTrxDataProvider(metadata: metadata, submitAction: self.submit))

        case .failure(let error):
          result = .failure(error)
        }

        self.addTransactionVM =
          AddTransactionViewModel(result: result,
                                  refreshAction: self.addTransactionRefreshCallback)
        self.objectWillChange.send()
      }
  }

  func submit(transaction: Transaction, resultHandler: @escaping SubmitResultHandler) {
    scriptManager.addTransaction(for: user!, transaction: transaction) { result in
      switch result {
      case .success:
        resultHandler(.success(()))
      case .failure(let error):
        resultHandler(.failure(error))
      }
    }
  }

  func changeSheet() {
    self.appDefaults.clearDefaultFile()
    handle(state: .changeSheet)
    self.addTransactionVM =
      AddTransactionViewModel(refreshAction: self.addTransactionRefreshCallback)
    handle(state: .authenticatedLocally)
    Logger.info("Sheet changed")
    self.objectWillChange.send()
  }
}

// MARK: - State Management
extension AppCoordinator {
  func handle(state: AppState) {
    switch state {
    case .loggedOut:
//      userManager.authenticate()
    break

    case .verifiedExternally:
//      self.localAuthorizer
//        .authenticateUserLocally {
//          self.stateManager.processEvent(event: .authenticatedLocally(result: $0))
//        }
    break

    case .authenticatedLocally:
      guard let sheet = self.appDefaults.getDefaultSheet() else {
//        remoteFileManager.getFileList(for: self.user!)
        return
      }
      self.stateManager.processEvent(event: .hasDefaultFile)
      self.selectedFile = sheet.file
      self.dataLocationMap = sheet.dataMap

    case .changeSheet:
      self.stateManager.processEvent(event: .changeSheet)

    default:
      print("The current state is \(state)")
    }
  }
}

// MARK: - Computed Properties
extension AppCoordinator {
  var needsLocalAuth: Bool {
    stateManager.needsLocalAuth
  }

  var isLoggedOut: Bool {
    user == nil
  }

  var hasDefaultSheet: Bool {
    selectedSheet != nil
  }
}
