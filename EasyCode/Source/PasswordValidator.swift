//
//  PasswordValidator.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

/// An enumeration representing different password validation rules.
public enum ValidationRule: Hashable {

    /// Rule to ensure the password contains only Latin characters.
    case latinCharacters
    /// Rule to ensure the password meets a minimum length.
    case minLength(minLength: Int = 7)
    /// Rule to ensure the password contains at least one uppercase character.
    case uppercase
    /// Rule to ensure the password contains at least one digit.
    case digit
    /// Rule to ensure the password contains specific special characters.
    case specialCharacters(characters: String = "!?*#$&%@_-", count: Int = 2)
    /// Rule to apply a custom validation function to the password.
    case custom(name: String, (String) -> Bool)

    private var key: String {
        switch self {
        case .latinCharacters: return "latinCharacters"
        case .minLength: return "minLength"
        case .uppercase: return "uppercase"
        case .digit: return "digit"
        case .specialCharacters: return "specialCharacters"
        case .custom(let name, _): return name
        }
    }

    public func hash(into hasher: inout Hasher) { hasher.combine(key) }

    public static func == (lhs: ValidationRule, rhs: ValidationRule) -> Bool { lhs.key == rhs.key }
}

/// Protocol defining a strategy for validating passwords.
public protocol PasswordValidationStrategy {
    var rule: ValidationRule { get set }
    func isValid(password: String) -> Bool
}

class LatinCharactersValidation: PasswordValidationStrategy {

    var rule: ValidationRule

    init(rule: ValidationRule) {
        self.rule = rule
    }

    func isValid(password: String) -> Bool {
        let latinPattern = "^[a-zA-Z0-9!?*#$&%@_-]{1,}$"
        return password.range(of: latinPattern, options: .regularExpression) != nil
    }
}

class LengthValidation: PasswordValidationStrategy {

    var rule: ValidationRule
    private let minLength: Int

    init(minLength: Int, rule: ValidationRule) {
        self.minLength = minLength
        self.rule = rule
    }

    func isValid(password: String) -> Bool { password.count > minLength }
}

class UppercaseValidation: PasswordValidationStrategy {

    var rule: ValidationRule

    init(rule: ValidationRule) {
        self.rule = rule
    }

    func isValid(password: String) -> Bool { password.contains { $0.isUppercase } }
}

class DigitValidation: PasswordValidationStrategy {

    var rule: ValidationRule

    init(rule: ValidationRule) {
        self.rule = rule
    }

    func isValid(password: String) -> Bool { password.contains { Int(String($0)) != nil } }
}

class SpecialCharactersValidation: PasswordValidationStrategy {

    var rule: ValidationRule
    private let specialCharacters: String
    private let maxCount: Int

    init(specialCharacters: String, maxCount: Int, rule: ValidationRule) {
        self.specialCharacters = specialCharacters
        self.maxCount = maxCount
        self.rule = rule
    }

    func isValid(password: String) -> Bool {
        return password.filter(specialCharacters.contains).count <= maxCount && !password.isEmpty
    }
}

class CustomValidation: PasswordValidationStrategy {

    var rule: ValidationRule
    private let validationClosure: (String) -> Bool

    init(validationClosure: @escaping (String) -> Bool, rule: ValidationRule) {
        self.validationClosure = validationClosure
        self.rule = rule
    }

    func isValid(password: String) -> Bool { validationClosure(password) }
}

/// Class responsible for validating passwords using various strategies.
/// - Parameter strategies: The list of strategies to be used for validation.
///
/// # Example:
/// ``` swift
/// // Define the validation rules
/// let rules: [ValidationRule] = [
///     .latinCharacters,
///     .minLength(minLength: 8),
///     .uppercase,
///     .digit,
///     .specialCharacters(characters: "!@#$", count: 1),
///     .custom(name: "No whitespace") { password in
///         return !password.contains { $0.isWhitespace }
///     }
/// ]
///
/// // Create the validation strategies using the factory
/// let strategies = PasswordValidationFactory.createStrategies(rules: rules)
///
/// // Initialize the password validator with the strategies
/// let validator = PasswordValidator(strategies: strategies)
///
/// // Validate a password
/// let password = "Password123!"
/// let results = validator.isValid(password: password)
///
/// // Print validation results
/// for (rule, isValid) in results {
///     print("Rule: \(rule), Is Valid: \(isValid)")
/// }
/// ```
public class PasswordValidator {

    private var strategies: [PasswordValidationStrategy]

    /// Initializes the PasswordValidator with a list of validation strategies.
    /// - Parameter strategies: The list of strategies to be used for validation.
    ///
    /// # Example:
    /// ``` swift
    /// // Define the validation rules
    /// let rules: [ValidationRule] = [
    ///     .latinCharacters,
    ///     .minLength(minLength: 8),
    ///     .uppercase,
    ///     .digit,
    ///     .specialCharacters(characters: "!@#$", count: 1),
    ///     .custom(name: "No whitespace") { password in
    ///         return !password.contains { $0.isWhitespace }
    ///     }
    /// ]
    ///
    /// // Create the validation strategies using the factory
    /// let strategies = PasswordValidationFactory.createStrategies(rules: rules)
    ///
    /// // Initialize the password validator with the strategies
    /// let validator = PasswordValidator(strategies: strategies)
    ///
    /// // Validate a password
    /// let password = "Password123!"
    /// let results = validator.isValid(password: password)
    ///
    /// // Print validation results
    /// for (rule, isValid) in results {
    ///     print("Rule: \(rule), Is Valid: \(isValid)")
    /// }
    /// ```
    public init(strategies: [PasswordValidationStrategy]) {
        self.strategies = strategies
    }

    /// Validates the password using the defined strategies.
    /// - Parameter password: The password to be validated.
    /// - Returns: A dictionary with the validation results for each rule.
    public func isValid(password: String) -> [ValidationRule: Bool] {
        var results: [ValidationRule: Bool] = [:]
        for strategy in strategies {
            results[strategy.rule] = strategy.isValid(password: password)
        }
        return results
    }

    public func isValid(password: String) -> Bool {
        var results: [ValidationRule: Bool] = [:]
        for strategy in strategies {
            results[strategy.rule] = strategy.isValid(password: password)
        }
        return !results.compactMap { $0.value }.contains(false)
    }
}

/// Factory class for creating password validation strategies based on rules.
///
/// # Example:
/// ``` swift
/// // Define the validation rules
/// let rules: [ValidationRule] = [
///     .latinCharacters,
///     .minLength(minLength: 8),
///     .uppercase,
///     .digit,
///     .specialCharacters(characters: "!@#$", count: 1),
///     .custom(name: "No whitespace") { password in
///         return !password.contains { $0.isWhitespace }
///     }
/// ]
///
/// // Create the validation strategies using the factory
/// let strategies = PasswordValidationFactory.createStrategies(rules: rules)
///
/// // Now you can use these strategies to initialize the PasswordValidator
/// let validator = PasswordValidator(strategies: strategies)
///
/// // Validate a password
/// let password = "Password123!"
/// let results = validator.isValid(password: password)
///
/// // Print validation results
/// for (rule, isValid) in results {
///     print("Rule: \(rule), Is Valid: \(isValid)")
/// }
/// ```
public class PasswordValidationFactory {

    /// Creates a list of password validation strategies based on the given rules.
    /// - Parameter rules: The validation rules to be used.
    /// - Returns: A list of password validation strategies.
    ///
    /// # Example:
    /// ``` swift
    /// // Define the validation rules
    /// let rules: [ValidationRule] = [
    ///     .latinCharacters,
    ///     .minLength(minLength: 8),
    ///     .uppercase,
    ///     .digit,
    ///     .specialCharacters(characters: "!@#$", count: 1),
    ///     .custom(name: "No whitespace") { password in
    ///         return !password.contains { $0.isWhitespace }
    ///     }
    /// ]
    ///
    /// // Create the validation strategies using the factory
    /// let strategies = PasswordValidationFactory.createStrategies(rules: rules)
    ///
    /// // Now you can use these strategies to initialize the PasswordValidator
    /// let validator = PasswordValidator(strategies: strategies)
    ///
    /// // Validate a password
    /// let password = "Password123!"
    /// let results = validator.isValid(password: password)
    ///
    /// // Print validation results
    /// for (rule, isValid) in results {
    ///     print("Rule: \(rule), Is Valid: \(isValid)")
    /// }
    /// ```
    public static func createStrategies(rules: [ValidationRule]) -> [PasswordValidationStrategy] {
        return rules.map { rule in
            switch rule {
            case .latinCharacters:
                return LatinCharactersValidation(rule: rule)
            case .minLength(let length):
                return LengthValidation(minLength: length, rule: rule)
            case .uppercase:
                return UppercaseValidation(rule: rule)
            case .digit:
                return DigitValidation(rule: rule)
            case .specialCharacters(let characters, let maxCount):
                return SpecialCharactersValidation(specialCharacters: characters, maxCount: maxCount, rule: rule)
            case .custom(_, let closure):
                return CustomValidation(validationClosure: closure, rule: rule)
            }
        }
    }
}
