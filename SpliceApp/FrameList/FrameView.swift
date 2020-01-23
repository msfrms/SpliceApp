//
//  FrameView.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import Foundation
import UIKit

public class FrameView: UIView {
    public struct Props {
        public let image: UIImage?
        public let onTap: CommandWith<UIViewController>
    }
    private let imageView = UIImageView()
    private var props = Props(image: UIImage(), onTap: .nop)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.backgroundColor = .gray

        addSubview(imageView)

        let constraints: [NSLayoutConstraint] = [
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    public func render(props: Props) {
        self.props = props

        imageView.image = props.image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
