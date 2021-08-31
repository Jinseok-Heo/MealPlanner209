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
    var leftImageView: UIImageView!
    var stackView: UIStackView!
    
    let attributes: [NSAttributedString.Key:Any] = [
        .backgroundColor : UIColor.clear.cgColor,
        .font : UIFont(name: "Noteworthy", size: 15)!,
        .foregroundColor : UIColor.black.cgColor,
    ]
    
    let titleAttributes: [NSAttributedString.Key:Any] = [
        .backgroundColor : UIColor.clear.cgColor,
        .font : UIFont(name: "Noteworthy Bold", size: 20)!,
        .foregroundColor: UIColor.black.cgColor
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
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.5
        self.image = image
        self.food = food
        titleText = food.name
        caloriesText = "Calrories: " + String(food.calories) + "kcal"
        carbsText = "Carbs: " + String(food.carbohydrates) + "g"
        proteinsText = "Protein: " + String(food.proteins) + "g"
        fatsText = "Fat: " + String(food.fats) + "g"
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        
    }
    
    private func setupViews() {
        setupLeftImageView()
        setupLabels()
        setupTitleLabel()
    }
    
    private func setupLeftImageView() {
        leftImageView = UIImageView()
        leftImageView.layer.borderWidth = 1
        leftImageView.layer.borderColor = UIColor.black.cgColor
        leftImageView.frame.size = CGSize(width: self.bounds.height - 4, height: self.bounds.height - 4)
        if let image = image {
            leftImageView.image = ImageHandler.resizeImage(image: image, targetSize: leftImageView.frame.size)
        }
        addSubview(leftImageView)
        setupLeftImageViewConstraints()
    }
    
    private func setupLeftImageViewConstraints() {
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.widthAnchor.constraint(equalToConstant: self.bounds.height - 4).isActive = true
        leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1).isActive = true
        leftImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    private func setupLabels() {
        let caloriesLabel = setupTextLabel(text: caloriesText ?? "0kcal")
        let carbsLabel = setupTextLabel(text: carbsText ?? "0g")
        let proteinLabel = setupTextLabel(text: proteinsText ?? "0g")
        let fatLabel = setupTextLabel(text: fatsText ?? "0g")
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        stackView.addArrangedSubview(caloriesLabel)
        stackView.addArrangedSubview(carbsLabel)
        stackView.addArrangedSubview(proteinLabel)
        stackView.addArrangedSubview(fatLabel)
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 130).isActive = true
    }
    
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: titleText!, attributes: titleAttributes)
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 10).isActive = true
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
