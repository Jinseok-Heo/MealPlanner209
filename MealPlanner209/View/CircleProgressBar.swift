//
//  CircleProgressBar.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/30.
//

import UIKit

class CircularProgressBar: UIView {
    
    var title: String!
    var maxValue: Double!
    var currentValue: Double!
    var ringWidth: CGFloat!
    var ringColor: UIColor!
    var gradientColor: UIColor!
    var progress: CGFloat {
        return min(CGFloat(currentValue / maxValue), 1)
    }
    
    private var barView = UIView()
    private var progressLayer = CAShapeLayer()
    private var textLayer = CATextLayer()
    private var gradientLayer = CAGradientLayer()
    private var backgroundMask = CAShapeLayer()
    
    init(frame: CGRect, title: String, maxValue: Double, currentValue: Double) {
        super.init(frame: frame)
        barView.frame = frame
        setupProperties(title: title, maxValue: maxValue, currentValue: currentValue)
        setupLayers()
        createAnimation()
        self.addSubview(barView)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateLayer(newMaxValue: Double, newCurrentValue: Double) {
        print("update layer in \(title!)")
        removeLayer()
        maxValue = newMaxValue
        currentValue = newCurrentValue
        setupLayers()
        createAnimation()
        self.addSubview(barView)
        setupLabel()
    }
    
    func removeLayer() {
        guard let layers = self.layer.sublayers else { return }
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        barView = UIView(frame: self.bounds)
        progressLayer = CAShapeLayer()
        textLayer = CATextLayer()
        gradientLayer = CAGradientLayer()
        backgroundMask = CAShapeLayer()
    }
    
    private func setupProperties(title: String, maxValue: Double, currentValue: Double) {
        self.title = title
        self.maxValue = maxValue
        self.currentValue = currentValue
        
        self.ringWidth = 8
        self.ringColor = UIColor.gray
        self.gradientColor = .white
    }
    
    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.strokeColor = UIColor.blue.cgColor
        barView.layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        barView.layer.addSublayer(gradientLayer)
        barView.layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)

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
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))

        backgroundMask.path = circlePath.cgPath
        
        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [ringColor.cgColor, gradientColor.cgColor, ringColor.cgColor]
    }
    
    private func setupLabel() {
        textLayer = CATextLayer()
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let width: CGFloat = 60
        let height: CGFloat = 60
        textLayer.frame = CGRect(x: center.x - width / 2,
                                 y: center.y - height / 2 + 10,
                                 width: width,
                                 height: height)
        textLayer.alignmentMode = .center
        textLayer.font = UIFont(name: "Noteworthy Bold", size: 10) as CFTypeRef
        textLayer.fontSize = 12
        textLayer.isWrapped = true
        
        let string = String(currentValue) + "g " + String(maxValue) + "g"
        textLayer.string = string
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor

        self.layer.addSublayer(textLayer)
    }
    
}



