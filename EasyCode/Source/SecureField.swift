//
//  SecureField.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import UIKit

public class SecureField: UITextField {

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        self.isSecureTextEntry = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    weak var secureContainer: UIView? {
        let secureView = subviews.first { type(of: $0).description().contains("CanvasView") }
        secureView?.translatesAutoresizingMaskIntoConstraints = false
        secureView?.isUserInteractionEnabled = true
        return secureView
    }

    public override var canBecomeFirstResponder: Bool { false }
    public override func becomeFirstResponder() -> Bool { false }

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
