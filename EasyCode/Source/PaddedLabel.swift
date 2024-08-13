//
//  PaddedLabel.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 13.08.2024.
//

import UIKit

/// `PaddedLabel` is a custom subclass of `UILabel` that adds padding around the label's text content.
///
/// This class allows you to specify custom insets (padding) for the label's content, which is useful for adjusting the
/// spacing between the label's text and its boundaries. The `PaddedLabel` class overrides the `intrinsicContentSize`
/// and `drawText(in:)` methods to account for the specified padding, ensuring that the label's size and text rendering
/// reflect the added insets.
///
/// # Example Usage:
/// ```swift
/// let label = PaddedLabel()
/// label.text = "Hello, World!"
/// label.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
/// label.backgroundColor = .lightGray
/// ```
///
/// In the example above, a `PaddedLabel` is created with custom content insets, making the text appear with 10 points
/// of padding at the top and bottom, and 15 points on the left and right. The background color is set to light gray
/// to better visualize the padding effect.
public class PaddedLabel: UILabel {

    /// The insets (padding) to apply around the label's text content.
    ///
    /// This property defines the amount of space to be added around the text inside the label. By default, the insets
    /// are set to `(top: 5, left: 8, bottom: 5, right: 8)`.
    public var contentInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)

    /// Calculates the intrinsic content size of the label, including the specified content insets.
    ///
    /// This method overrides the default `intrinsicContentSize` property to account for the `contentInsets` property.
    /// It calculates the new size of the label by adding the insets to the original content size. This ensures that the
    /// label's size includes the specified padding.
    ///
    /// - Returns: The intrinsic content size of the label, including padding.
    public override var intrinsicContentSize: CGSize {
        let width = contentInsets.left + super.intrinsicContentSize.width + contentInsets.right
        let height = contentInsets.top + super.intrinsicContentSize.height + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

    /// Draws the label's text within the specified rectangle, applying the content insets.
    ///
    /// This method overrides the `drawText(in:)` method to ensure that the label's text is drawn inside the area defined
    /// by the `contentInsets`. The text is effectively shifted inward by the inset values, creating padding between the
    /// text and the label's edges.
    ///
    /// - Parameter rect: The rectangle in which to draw the text.
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
}
