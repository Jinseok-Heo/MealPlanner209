//
//  HomeSubView.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/27.
//

import UIKit
import CoreData

class HomeSubView: UIView {
    
    var image: UIImage?
    var titleText: String?
    var caloriesText: String?
    var carbsText: String?
    var proteinsText: String?
    var fatsText: String?
    var food: Food?
    var fetchedResultController: NSFetchedResultsController<History>?
    
    let attributes: [NSAttributedString.Key:Any] = [
        .backgroundColor : UIColor.cyan.cgColor,
        .font : UIFont(name: "Noteworthy", size: 15)!,
        .foregroundColor : UIColor.black.cgColor,
        .strokeWidth : 1
    ]
    
    init(frame: CGRect, image: UIImage, food: Food, fetchedResultController: NSFetchedResultsController<History>) {
        super.init(frame: frame)
        self.fetchedResultController = fetchedResultController
        configureProperties(image: image, food: food)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func configureProperties(image: UIImage, food: Food) {
        self.image = image
        self.food = food
        titleText = food.name
        caloriesText = String(food.calories)
        carbsText = String(food.carbohydrates)
        proteinsText = String(food.proteins)
        fatsText = String(food.fats)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        
    }
    
    private func setupViews() {
        self.backgroundColor = .gray
        
        let leftImageView = UIImageView(frame: CGRect(x: self.bounds.minX,
                                                      y: self.bounds.minY,
                                                      width: self.bounds.height,
                                                      height: self.bounds.height))
        leftImageView.layer.borderWidth = 1
        leftImageView.layer.borderColor = UIColor.black.cgColor
        if let image = image {
            leftImageView.image = ImageHandler.resizeImage(image: image, targetSize: leftImageView.frame.size)
        }
        addSubview(leftImageView)
        leftImageView.widthAnchor.constraint(equalToConstant: self.bounds.height - 4).isActive = true
        leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1).isActive = true
        leftImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let caloriesLabel = setupTextLabel(text: caloriesText ?? "0" + "kcal")
        let carbsLabel = setupTextLabel(text: carbsText ?? "0g")
        let proteinLabel = setupTextLabel(text: proteinsText ?? "0g")
        let fatLabel = setupTextLabel(text: fatsText ?? "0")
        
        let stackView = UIStackView()
        stackView.addSubview(caloriesLabel)
        stackView.addSubview(carbsLabel)
        stackView.addSubview(proteinLabel)
        stackView.addSubview(fatLabel)
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let titleLabel = setupTextLabel(text: titleText ?? "Title")
        addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 10).isActive = true
        
//        let titleLabel = UILabel(frame: CGRect(x: leftImageView.frame.maxX + 10,
//                                               y: self.bounds.midY - 15,
//                                               width: 100,
//                                               height: 30))
//        titleLabel.backgroundColor = .cyan
//        titleLabel.font = UIFont(name: "Noteworthy", size: 15)
//        titleLabel.textColor = .black
//        titleLabel.textAlignment = .left
//        titleLabel.text = titleText
//        addSubview(titleLabel)
        
//        let calorieLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + 30,
//                                                 y: self.bounds.midY - 15,
//                                                 width: 40,
//                                                 height: 30))
//        calorieLabel.backgroundColor = .cyan
//        calorieLabel.font = UIFont(name: "Noteworthy", size: 15)
//        calorieLabel.textColor = .black
//        calorieLabel.textAlignment = .left
//        calorieLabel.text = caloriesText ?? "" + "kcal"
//        addSubview(calorieLabel)
    }
    
    private func setupTextLabel(text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        return label
    }
    
    private func deleteFood() {
        guard let fetchedObject = fetchedResultController?.fetchedObjects else {
            return
        }
        if food != nil {
            fetchedObject.first?.removeFromFoods(food!)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer?=nil) {
        self.removeFromSuperview()
        deleteFood()
    }
    
}
