//
//  LoggerDetailsViewController.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

#if os(iOS)

import UIKit

class LoggerDetailsViewController: UITableViewController {

    private var endpoint: NSAttributedString?
    private var requestHeaders: [NSAttributedString] = []
    private var requestBody: [NSAttributedString] = []
    private var responseHeaders: [NSAttributedString] = []
    private var responseBody: [NSAttributedString] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        stylize()
    }

    private func stylize() {
        title = "Request"
        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc"),
            style: .plain,
            target: self,
            action: #selector(copyAction)
        )

        tableView.separatorStyle = .none
        tableView.register(LoggerDetailCell.self)
    }

    @objc private func copyAction() {
        let attributedString = NSMutableAttributedString()

        if let endpoint = endpoint {
            attributedString.append(endpoint)
            attributedString.append(NSAttributedString(string: "\n\n===========================================\n\n"))
        }

        requestHeaders.forEach { string in
            attributedString.append(string)
            attributedString.append(NSAttributedString(string: "\n"))
        }
        attributedString.append(NSAttributedString(string: "\n===========================================\n\n"))

        requestBody.forEach { string in
            attributedString.append(string)
            attributedString.append(NSAttributedString(string: "\n"))
        }
        attributedString.append(NSAttributedString(string: "\n===========================================\n\n"))

        responseHeaders.forEach { string in
            attributedString.append(string)
            attributedString.append(NSAttributedString(string: "\n"))
        }
        attributedString.append(NSAttributedString(string: "\n===========================================\n\n"))

        responseBody.forEach { string in
            attributedString.append(string)
            attributedString.append(NSAttributedString(string: "\n"))
        }

        UIPasteboard.general.string = attributedString.string
        UIImpactFeedbackGenerator().impactOccurred()
    }

    func set(
        endpoint: NSAttributedString,
        requestHeaders: [NSAttributedString],
        requestBody: [NSAttributedString],
        responseHeaders: [NSAttributedString],
        responseBody: [NSAttributedString]
    ) {
        self.endpoint = endpoint
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
    }
}

extension LoggerDetailsViewController {

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }

        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        header.contentView.backgroundColor = UIColor.white
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Endpoint"
        case 1: return "Request headers"
        case 2: return "Request body"
        case 3: return "Response headers"
        case 4: return "Response body"
        default: return nil
        }
    }
}

extension LoggerDetailsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int { 5 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return requestHeaders.count
        case 2: return requestBody.count
        case 3: return responseHeaders.count
        case 4: return responseBody.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LoggerDetailCell = tableView.dequeueReusableCell(for: indexPath)
        var strings: [NSAttributedString] = []

        switch indexPath.section {
        case 1: strings = requestHeaders
        case 2: strings = requestBody
        case 3: strings = responseHeaders
        case 4: strings = responseBody
        default: break
        }

        if indexPath.section == 0 {
            cell.label.attributedText = endpoint
        } else {
            cell.label.attributedText = strings[indexPath.row]
        }

        return cell
    }
}

extension LoggerDetailsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let string: String

        switch indexPath.section {
        case 0:
            guard let endpoint = endpoint else { return }
            string = endpoint.string
        case 1:
            string = requestHeaders[indexPath.row].string
        case 2:
            string = requestBody[indexPath.row].string
        case 3:
            string = responseHeaders[indexPath.row].string
        case 4:
            string = responseBody[indexPath.row].string
        default:
            return
        }

        UIPasteboard.general.string = string
        UIImpactFeedbackGenerator().impactOccurred()
    }
}

#endif
