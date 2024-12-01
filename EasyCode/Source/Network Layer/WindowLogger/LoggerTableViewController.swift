//
//  LoggerTableViewController.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation
#if os(iOS)

import UIKit

class LoggerTableViewController: UITableViewController {

    private var rows: [LoggerRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        stylize()
        setActions()
    }

    private func stylize() {
        title = "Logger"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(clearLog)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonAction)
        )

        tableView.separatorInset.left = 16
        tableView.separatorInset.top = 16
    }

    private func setActions() {
        tableView.register(LoggerCell.self)
    }

    @objc private func clearLog() {
        rows.removeAll()
        tableView.reloadData()
    }

    @objc private func closeButtonAction() { NetworkGlobals.dismissWithNewWindow() }

    func insert(row: LoggerRow) {
        DispatchQueue.main.async { [weak self] in
            guard let viewController = self else { return }

            viewController.rows.insert(row, at: 0)

            viewController.tableView.beginUpdates()
            viewController.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            viewController.tableView.endUpdates()
        }
    }

    func update(id: UUID, response: NetworkResponseProtocol) {
        DispatchQueue.main.async { [weak self] in
            guard let viewController = self,
                  let index = viewController.rows.firstIndex(where: { $0.request.id == id }) else {
                return
            }

            viewController.rows[index].response = response
            viewController.rows[index].endDate = Date()
            viewController.tableView.beginUpdates()
            viewController.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            viewController.tableView.endUpdates()
        }
    }
}

extension LoggerTableViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 78 }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let requestHeaders = rows[indexPath.row].requestHeaders,
              let requestBody = rows[indexPath.row].requestBody,
              let responseHeaders = rows[indexPath.row].responseHeaders,
              let responseBody = rows[indexPath.row].responseBody else {
            return
        }

        let viewController = LoggerDetailsViewController()
        viewController.set(
            endpoint: rows[indexPath.row].endpoint,
            requestHeaders: requestHeaders,
            requestBody: requestBody,
            responseHeaders: responseHeaders,
            responseBody: responseBody
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LoggerTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LoggerCell = tableView.dequeueReusableCell(for: indexPath)
        let row = rows[indexPath.row]
        cell.endpoint = row.endpoint.string
        cell.host = row.host
        cell.isSuccess = row.response?.success == true
        cell.status = row.status
        cell.method = row.method
        cell.time = row.formattedResponseTime
        cell.isLoading = row.response == nil
        return cell
    }
}

#endif
