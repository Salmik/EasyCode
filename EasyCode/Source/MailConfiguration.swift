//
//  MailConfiguration.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import Foundation

public struct MailConfiguration {

    public var subject = ""
    public var recipients: [String] = []
    public var messageBody = ""
    public var isBodyHtml = false
}
