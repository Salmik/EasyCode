//
//  UICollectionView+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit

public extension UICollectionView {

    /// Registers a reusable cell type for use in creating new collection view cells.
    ///
    /// - Parameter T: The type of the cell to register, conforming to `UICollectionViewCell`.
    ///
    /// # Example:
    /// ``` swift
    /// collectionView.register(MyCustomCell.self)
    /// ```
    /// This registers `MyCustomCell` to be used in the collection view.
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseId)
    }

    /// Dequeues a reusable collection view cell for the specified index path.
    ///
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A dequeued cell of the specified type.
    ///
    /// # Example:
    /// ``` swift
    /// let cell: MyCustomCell = collectionView.dequeueReusableCell(for: indexPath)
    /// ```
    /// This dequeues `MyCustomCell` for the given index path.
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }

    /// Registers a reusable supplementary view type for use in creating new supplementary views.
    ///
    /// - Parameters:
    ///   - T: The type of the supplementary view to register, conforming to `UICollectionReusableView`.
    ///   - forSupplementaryViewOfKind: The kind of supplementary view to register (e.g., header or footer).
    ///
    /// # Example:
    /// ``` swift
    /// collectionView.register(MyHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    /// ```
    /// This registers `MyHeaderView` as a supplementary view for headers in the collection view.
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind: String) {
        register(T.self, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: T.reuseId)
    }

    /// Dequeues a reusable supplementary view for the specified kind and index path.
    ///
    /// - Parameters:
    ///   - ofKind: The kind of supplementary view to dequeue (e.g., header or footer).
    ///   - indexPath: The index path specifying the location of the supplementary view.
    /// - Returns: A dequeued supplementary view of the specified type.
    ///
    /// # Example:
    /// ``` swift
    /// let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath) as MyHeaderView
    /// ```
    /// This dequeues `MyHeaderView` for the given kind (header) and index path.
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: ofKind,
            withReuseIdentifier: T.reuseId,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.reuseId)")
        }
        return view
    }
}
