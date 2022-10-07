//
// PayeeStorage.swift
// Aspire Budgeting
//

import Foundation

class PayeeStorage {
  static func set(recentCategory category: String, for payee: String) {
    var existing = categories(for: payee)
    existing.removeAll { $0 == category }
    existing = [category] + existing
    UserDefaults.standard.set(existing, forKey: categoryKey(for: payee))
  }

  static func orderedCategories(for payee: String, unorderedCategories: [String]) -> [String] {
    let matched = categories(for: payee)
    var unmatched = unorderedCategories
    unmatched.removeAll { matched.contains($0) }
    return matched + unmatched
  }

  static func recentCategory(for payee: String) -> String? {
    return categories(for: payee).first
  }

  static func set(recentAccount account: String, for payee: String) {
    var existing = accounts(for: payee)
    existing.removeAll { $0 == account }
    existing = [account] + existing
    UserDefaults.standard.set(existing, forKey: accountKey(for: payee))
  }

  static func orderedAccounts(for payee: String, unorderedAccounts: [String]) -> [String] {
    let matched = accounts(for: payee)
    var unmatched = unorderedAccounts
    unmatched.removeAll { matched.contains($0) }
    return matched + unmatched
  }

  static func recentAccount(for payee: String) -> String? {
    return accounts(for: payee).first
  }

  static func clearData(allCategories: [String], allAccounts: [String]) {
    allCategories.forEach { UserDefaults.standard.removeObject(forKey: categoryKey(for: $0)) }
    allAccounts.forEach { UserDefaults.standard.removeObject(forKey: accountKey(for: $0)) }
  }

  private static func categoryKey(for payee: String) -> String {
    return "payee-category-\(payee)"
  }

  private static func accountKey(for payee: String) -> String {
    return "payee-account-\(payee)"
  }

  private static func categories(for payee: String) -> [String] {
    return UserDefaults.standard.array(forKey: categoryKey(for: payee)) as? [String] ?? []
  }

  private static func accounts(for payee: String) -> [String] {
    return UserDefaults.standard.array(forKey: accountKey(for: payee)) as? [String] ?? []
  }
}
