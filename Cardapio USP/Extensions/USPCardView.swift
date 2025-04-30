//
//  USPCardView.swift
//  banner
//
//  Created by Vagner Machado on 16/04/25.
//

import UIKit

class USPCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.uspBorder.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
