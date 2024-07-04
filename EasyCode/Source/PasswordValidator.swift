//
//  PasswordValidator.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

public enum ValidationRule: Hashable {

    case latinCharacters
    case minLength(minLength: Int = 7)
    case uppercase
    case digit
    case specialCharacters(characters: String = "!?*#$&%@_-", count: Int = 2)
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

public class PasswordValidator {

    private var strategies: [PasswordValidationStrategy]

    public init(strategies: [PasswordValidationStrategy]) {
        self.strategies = strategies
    }

    public func isValid(password: String) -> [ValidationRule: Bool] {
        var results: [ValidationRule: Bool] = [:]
        for strategy in strategies {
            results[strategy.rule] = strategy.isValid(password: password)
        }
        return results
    }
}

public class PasswordValidationFactory {

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
