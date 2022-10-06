//
// GoogleScriptManager.swift
// Aspire Budgeting
//


import GoogleAPIClientForREST

final class GoogleScriptManager {
  private let scriptService: GTLRService
  // deployment id for version 1
  private let scriptId = "AKfycbzQXm8R4WT2BY7ATcxkJSNUnRY1-4h7JVs0oZ01Mt36ROHM1ja5838IcZAAkbLFff57"

  init() {
    scriptService = GTLRScriptService()
  }

  func updateBudget(for user: User, completion: @escaping (Result<Bool>) -> Void) {
    run(for: user, function: "topUpMonthlyBudget", params: nil, completion: completion)
  }

  func addTransaction(for user: User, transaction: Transaction, completion: @escaping (Result<Bool>) -> Void) {
    run(for: user, function: "recordTransaction", params: transaction.param, completion: completion)
  }

  private func run(for user: User, function: String?, params: [Any]?, completion: @escaping (Result<Bool>) -> Void) {
    let request = GTLRScript_ExecutionRequest()
    request.function = function
    request.parameters = params
    request.devMode = true
    let query = GTLRScriptQuery_ScriptsRun.query(withObject: request, scriptId: scriptId)
    scriptService.authorizer = user.authorizer
    scriptService.executeQuery(query) { _, response, error in
      // https://developers.google.com/apps-script/api/reference/rest/v1/scripts/run#response-body
      if let error = error {
        Logger.error(
          "Error while running script.",
          context: error.localizedDescription
        )
        completion(.failure(error))
      } else if let response = response as? GTLRObject {
        completion(.success(response.json?["done"] as? Int == 1))
      } else {
        completion(.success(false))
      }
    }
  }
}
