//
//  CustomCircleProgressBar.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/15.
//

import UIKit

@IBDesignable
class CircleProgressBar: UIView {
    
    @IBInspectable var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var ringWidth: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var title: String = "" {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var gradientColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    private let progressLayer = CAShapeLayer()
    private let labelLayer = CATextLayer()
    private let gradientLayer = CAGradientLayer()
    private let backgroundMask = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("Frame")
        setupLayers()
        createAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("Coder")
        setupLayers()
        createAnimation()
    }
    
    override func draw(_ rect: CGRect) {
        print("Draw")
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
    }
    
    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(gradientLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
    }
    
    private func createAnimation() {
        let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        startPointAnimation.values = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]

        startPointAnimation.repeatCount = Float.infinity
        startPointAnimation.duration = 1

        let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
        endPointAnimation.values = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint.zero]

        endPointAnimation.repeatCount = Float.infinity
        endPointAnimation.duration = 1

        gradientLayer.add(startPointAnimation, forKey: "startPointAnimation")
        gradientLayer.add(endPointAnimation, forKey: "endPointAnimation")
    }
    
//    private func setAnimation() {
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 2
//        self.layer.add(animation, forKey: "strokeEnd")
//    }
//
    private func setLabelLayer() {
        labelLayer.string = title
        labelLayer.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: self.frame.width, height: 20)
        print(labelLayer.frame)
        labelLayer.font = UIFont(name: "Helvetica-Bold", size: 15)
        labelLayer.foregroundColor = UIColor.black.cgColor
        labelLayer.alignmentMode = .center
        labelLayer.isHidden = false
        labelLayer.zPosition = 3
        self.layer.addSublayer(labelLayer)
    }
    
}
