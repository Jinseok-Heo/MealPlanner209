//
//  LinearProgressBar.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/31.
//

import UIKit

class LinearProgressBar: UIView {
    
    let color: UIColor = .gray
    let gradientColor: UIColor = .white
    var maxValue: Double = 0
    var currentValue: Double = 2500
    
    var progress: CGFloat {
        return min(1, CGFloat(currentValue / maxValue))
    }
    
    private var barView = UIView()
    private var backgroundMask = CAShapeLayer()
    private var textLayer = CATextLayer()
    private var progressLayer = CALayer()
    private var gradientLayer = CAGradientLayer()
    
    init(frame: CGRect, maxValue: Double, currentValue: Double) {
        super.init(frame: frame)
        setupProperties(maxValue: maxValue, currentValue: currentValue)
        setupLayers()
        self.addSubview(barView)
        createAnimation()
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupProperties(maxValue: Double, currentValue: Double) {
        self.maxValue = maxValue
        self.currentValue = currentValue
        barView.frame = self.bounds
    }
    
    private func setupLayers() {
        barView.layer.addSublayer(gradientLayer)
        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    }

    private func createAnimation() {
        let flowAnimation = CABasicAnimation(keyPath: "locations")
        flowAnimation.fromValue = [-0.3, -0.15, 0]
        flowAnimation.toValue = [1, 1.15, 1.3]

        flowAnimation.isRemovedOnCompletion = false
        flowAnimation.repeatCount = Float.infinity
        flowAnimation.duration = 1

        gradientLayer.add(flowAnimation, forKey: "flowAnimation")
    }

    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        barView.layer.mask = backgroundMask

        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))

        progressLayer.frame = progressRect
        progressLayer.backgroundColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
        gradientLayer.endPoint = CGPoint(x: progress, y: 0.5)
    }
    
    private func setupLabel() {
        textLayer = CATextLayer()
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let width: CGFloat = 150
        let height: CGFloat = self.bounds.height / 2
        textLayer.frame = CGRect(x: center.x - width / 2,
                                 y: center.y - height / 2,
                                 width: width,
                                 height: height)
        textLayer.alignmentMode = .center
        textLayer.font = UIFont(name: "Noteworthy Bold", size: 10) as CFTypeRef
        textLayer.fontSize = 12
        
        let string = String(currentValue) + "kcal / " + String(maxValue) + "kcal"
        textLayer.string = string
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor

        self.layer.addSublayer(textLayer)
    }
    
}
