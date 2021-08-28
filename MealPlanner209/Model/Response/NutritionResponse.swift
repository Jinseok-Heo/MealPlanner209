//
//  NutritionResponse.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/24.
//

import Foundation

struct NutritionResponse: Codable {
    let id: Int?
    let title: String?
    let nutrition: Nutrition?
    let generatedText: String?
    let imageType: String?
}

struct Nutrition: Codable {
    let nutrients: [Nutrient]
    let caloricBreakdown: CaloricBreakdown?
    let calories: Double?
    let carbs: String?
    let protein: String?
    let fat: String?
}

struct Nutrient: Codable {
    let name: String?
    let amount: Double?
    let unit: String?
    let percentOfDailyNeeds: Double?
}

struct CaloricBreakdown: Codable {
    let percentProtein: Double?
    let percentFat: Double?
    let percentCarbs: Double?
}
