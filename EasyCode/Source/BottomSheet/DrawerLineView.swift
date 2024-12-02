//
//  DrawerLineView.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import UIKit

class DrawerLineView: UIView {

    private let lineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(lineView)
        setLayoutConstraints()
        stylize()
    }

    private func setLayoutConstraints() {
        lineView.constraintToCenter(of: self)
        lineView.constraintSize(to: .init(width: 40, height: 5))
    }

    private func stylize() {
        lineView.layer.cornerRadius = 2.5
        lineView.clipsToBounds = true
        lineView.backgroundColor = UIColor(hex: "#CFDDE4")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
