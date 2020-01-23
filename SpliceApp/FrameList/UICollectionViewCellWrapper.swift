//
//  UICollectionViewCellWrapper.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import UIKit

public class UICollectionViewCellWrapper: UICollectionViewCell {

    func wrapped(content: UIView) {
        content.removeFromSuperview()
        content.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(content)

        let constraints: [NSLayoutConstraint] = [
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leftAnchor.constraint(equalTo: leftAnchor),
            content.rightAnchor.constraint(equalTo: rightAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func wrapped(layer: CALayer) {
        layer.frame = contentView.frame
        contentView.layer.addSublayer(layer)
    }
}
