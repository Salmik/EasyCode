//
//  TipViewController.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 13.08.2024.
//

import UIKit

/// `TipViewController` is a custom view controller designed to display a tip or informational message to the user.
/// It presents an icon, a title, and a description, along with a close button for dismissing the view.
///
/// The `TipViewController` is intended to be used when you need to show a temporary, dismissible overlay with a brief
/// message or tip. The icon, title, and description can be customized through the initializer. This class provides
/// a simple and clean UI for showing helpful tips or notifications within your application.
///
/// # Example Usage:
/// ```swift
/// // Create an instance of TipViewController
/// let tipVC = TipViewController(image: UIImage(named: "info_icon"), title: "Tip Title", description: "This is a helpful tip.")
///
/// // Present the TipViewController
/// presentPopover(self, tipVC, sender: someView)
/// ```
///
/// The above example demonstrates how to create and present an instance of `TipViewController` with a custom icon, title, and description.
public class TipViewController: UIViewController {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    public init(image: UIImage?, title: String?, description: String?) {
        super.init(nibName: nil, bundle: nil)

        iconImageView.image = image
        titleLabel.text = title
        subtitleLabel.text = description
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setLayoutConstraints()
        stylyze()
        setActions()
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(iconImageView)
        view.addSubview(closeButton)
    }

    private func setLayoutConstraints() {
        iconImageView.makeConstraints { iconImageView in
            return [
                iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        }
        iconImageView.constraintSize(to: .init(width: 24, height: 24))

        titleLabel.makeConstraints { titleLabel in
            return [
                titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -12),
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
            ]
        }
        subtitleLabel.makeConstraints { subtitleLabel in
            return [
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36)
            ]
        }
        closeButton.makeConstraints { closeButton in
            return [
                closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
                closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
            ]
        }
        closeButton.constraintSize(to: .init(width: 24, height: 24))
    }

    private func stylyze() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4

        iconImageView.tintColor = .systemGray

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .systemGray
    }

    private func setActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc private func closeButtonTapped() { self.dismiss(animated: true) }
}
