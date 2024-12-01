//
//  LoggerCell.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation
#if os(iOS)

import UIKit

public class LoggerCell: UITableViewCell {

    private let stackView = UIStackView()
    private let urlStackView = UIStackView()
    private let endpointLabel = UILabel()
    private let hostLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView()
    private let additionalStackView = UIStackView()
    private let methodLabel = UILabel()
    private let statusLabel = UILabel()
    private let timeLabel = UILabel()

    var isSuccess: Bool? {
        didSet { statusLabel.textColor = isSuccess == true ? .green : .red }
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        addSubviews()
        stackView.constraintToEdges(of: contentView, insets: .init(top: 8, left: 16, bottom: 8, right: 16))
        stylize()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        isSuccess = nil
        endpoint = nil
        host = nil
        status = nil
        method = nil
        time = nil
        isLoading = true
    }

    private func addSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(urlStackView)
        urlStackView.addArrangedSubview(endpointLabel)
        urlStackView.addArrangedSubview(hostLabel)
        stackView.addArrangedSubview(activityIndicatorView)
        stackView.addArrangedSubview(additionalStackView)
        additionalStackView.addArrangedSubview(statusLabel)
        additionalStackView.addArrangedSubview(methodLabel)
        additionalStackView.addArrangedSubview(timeLabel)
    }

    private func stylize() {
        backgroundColor = .white
        contentView.backgroundColor = .white

        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center

        urlStackView.axis = .vertical
        urlStackView.spacing = 4

        endpointLabel.font = .systemFont(ofSize: 16, weight: .medium)
        endpointLabel.textColor = .gray

        hostLabel.font = .systemFont(ofSize: 12)
        hostLabel.textColor = .lightGray

        additionalStackView.axis = .vertical
        additionalStackView.spacing = 4
        additionalStackView.isHidden = true
        additionalStackView.setContentCompressionResistancePriority(.required, for: .vertical)

        statusLabel.font = .systemFont(ofSize: 16, weight: .bold)
        statusLabel.textAlignment = .right
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        methodLabel.font = .systemFont(ofSize: 16, weight: .bold)
        methodLabel.textAlignment = .right
        methodLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .right
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LoggerCell {

    var endpoint: String? {
        get { endpointLabel.text }
        set { endpointLabel.text = newValue }
    }

    var host: String? {
        get { hostLabel.text }
        set { hostLabel.text = newValue }
    }

    var status: String? {
        get { statusLabel.text }
        set { statusLabel.text = newValue }
    }

    var method: String? {
        get { methodLabel.text }
        set { methodLabel.text = newValue }
    }

    var time: String? {
        get { timeLabel.text }
        set { timeLabel.text = newValue }
    }

    var isLoading: Bool {
        get { activityIndicatorView.isAnimating }
        set {
            additionalStackView.isHidden = newValue
            newValue ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
}

#endif
