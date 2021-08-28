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
        if let image = image {
            leftImageView.image = ImageHandler.resizeImage(image: image, targetSize: leftImageView.frame.size)
        }
        addSubview(leftImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: leftImageView.frame.maxX + 10,
                                               y: self.bounds.midY - 15,
                                               width: 100,
                                               height: 30))
        titleLabel.backgroundColor = .cyan
        titleLabel.font = UIFont(name: "Noteworthy", size: 15)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.text = titleText
        addSubview(titleLabel)
        
        let calorieLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + 30,
                                                 y: self.bounds.midY - 15,
                                                 width: 40,
                                                 height: 30))
        calorieLabel.backgroundColor = .cyan
        calorieLabel.font = UIFont(name: "Noteworthy", size: 15)
        calorieLabel.textColor = .black
        calorieLabel.textAlignment = .left
        calorieLabel.text = titleText
        addSubview(calorieLabel)
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
