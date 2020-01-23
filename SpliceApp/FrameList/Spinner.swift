//
//  Spinner.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import UIKit
import QuartzCore

public class SpinnerLayer: CAShapeLayer {

    public var spinColor: UIColor = .gray

    public override init() {
        super.init()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func show(inFrame: CGRect) {

        let radius = inFrame.size.height / 2.0;
        let center = CGPoint(x: inFrame.width / 2.0, y: inFrame.height / 2.0)
        let pi_2 = Double.pi / 2.0
        let startAngle = -pi_2
        let endAngle = Double.pi * 2 - pi_2

        self.frame = CGRect(origin: inFrame.origin, size: CGSize(width: inFrame.height, height: inFrame.height))
        self.path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: CGFloat(startAngle),
                endAngle: CGFloat(endAngle),
                clockwise: true).cgPath
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 2.0;
        self.strokeEnd = 0.4;
        self.isHidden = false

    }

    public func start() {
        self.strokeColor = self.spinColor.cgColor
        self.isHidden = false

        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")

        rotate.fromValue = nil
        rotate.toValue = Double.pi * 2.0
        rotate.duration = 1.0
        rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotate.repeatCount = HUGE
        rotate.fillMode = CAMediaTimingFillMode.forwards
        rotate.isRemovedOnCompletion = false

        self.add(rotate, forKey:rotate.keyPath)
    }

    public func stop() {
        self.removeAllAnimations()
        self.isHidden = true
    }
}

public class SpinnerView: UIView {

    private let spinner = SpinnerLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(spinner)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func start() {
        spinner.start()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let spinHalfWidth: CGFloat = 25.0 / 2.0
        let spinHalfHeight: CGFloat = 25.0 / 2.0

        spinner.show(inFrame: CGRect(
            x: bounds.width / 2.0 - spinHalfWidth,
            y: bounds.height / 2.0 - spinHalfHeight,
            width: 25.0,
            height: 25.0))
        
        spinner.start()
    }
}
