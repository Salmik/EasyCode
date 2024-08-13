//
//  DynamicHeightCollectionView.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit

/// A custom `UICollectionView` subclass that adjusts its intrinsic content size based on its content.
///
/// This subclass automatically adjusts its intrinsic content size to match its `contentSize`,
/// ensuring correct layout behavior within auto layout constraints.
///
/// # Example usage:
/// ``` swift
/// let layout = UICollectionViewFlowLayout()
/// let collectionView = DynamicHeightCollectionView(layout: layout)
/// // Configure collection view properties or register cells here
/// ```
public class DynamicHeightCollectionView: UICollectionView {

    convenience public init(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.init(frame: .zero, collectionViewLayout: layout)
    }

    override public var intrinsicContentSize: CGSize { contentSize }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
}
