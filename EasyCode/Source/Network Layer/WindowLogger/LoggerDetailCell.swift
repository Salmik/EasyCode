//
//  LoggerDetailCell.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation

#if os(iOS)

import UIKit

class LoggerDetailCell: UITableViewCell {

    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        label.constraintToEdges(of: contentView, insets: .init(top: 8, left: 16, bottom: 8, right: 16))
        stylize()
    }

    private func stylize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
        label.numberOfLines = 0
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#endif
