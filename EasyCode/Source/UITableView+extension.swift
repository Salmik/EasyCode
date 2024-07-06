//
//  UITableView+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit

public extension UITableView {

    /// Registers a reusable cell type for use in creating new table view cells.
    ///
    /// - Parameter T: The type of the cell to register, conforming to `UITableViewCell`.
    ///
    /// # Example:
    /// ``` swift
    /// tableView.register(MyCustomCell.self)
    /// ```
    /// This registers `MyCustomCell` to be used in the table view.
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseId)
    }

    /// Registers a reusable header or footer view type for use in creating new header or footer views.
    ///
    /// - Parameter T: The type of the header or footer view to register, conforming to `UITableViewHeaderFooterView`.
    ///
    /// # Example:
    /// ``` swift
    /// tableView.register(MyHeaderView.self)
    /// ```
    /// This registers `MyHeaderView` to be used as a header or footer view in the table view.
    func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseId)
    }

    /// Dequeues a reusable table view cell for the specified index path.
    ///
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A dequeued cell of the specified type.
    ///
    /// # Example:
    /// ``` swift
    /// let cell: MyCustomCell = tableView.dequeueReusableCell(for: indexPath)
    /// ```
    /// This dequeues `MyCustomCell` for the given index path.
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }

    /// Dequeues a reusable header or footer view of the specified type.
    ///
    /// - Returns: A dequeued header or footer view of the specified type.
    ///
    /// # Example:
    /// ``` swift
    /// let headerView: MyHeaderView = tableView.dequeueReusableHeaderFooter()
    /// ```
    /// This dequeues `MyHeaderView` as a header or footer view.
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T {
        guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: T.reuseId) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return headerFooter
    }
}
