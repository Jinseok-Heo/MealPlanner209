//
//  CustomTextField.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/10.
//

import UIKit

@IBDesignable
class DesignableUITextField: UITextField {
    
    let imageWidth: CGFloat = 20
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateView()
    }
    
    // Provides left padding for images
    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var padding: UIEdgeInsets
        if let _ = leftImage {
            padding = UIEdgeInsets(top: 0, left: leftPadding * 2 + imageWidth, bottom: 0, right: 0)
        } else {
            padding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
        }
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var padding: UIEdgeInsets
        if let _ = leftImage {
            padding = UIEdgeInsets(top: 0, left: leftPadding * 2 + imageWidth, bottom: 0, right: 0)
        } else {
            padding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
        }
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var padding: UIEdgeInsets
        if let _ = leftImage {
            padding = UIEdgeInsets(top: 0, left: leftPadding * 2 + imageWidth, bottom: 0, right: 0)
        } else {
            padding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
        }
        return bounds.inset(by: padding)
    }
    
//    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        let padding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
//        return bounds.inset(by: padding)
//    }

    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var leftPadding: CGFloat = 0

    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: 20))
            let resizedImage = ImageHandler.resizeImage(image: image, targetSize: imageView.frame.size)
            imageView.contentMode = .scaleAspectFit
            imageView.image = resizedImage
            leftView = imageView
            
            
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }

}
