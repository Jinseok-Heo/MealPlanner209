//
//  NutritionResponse.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/24.
//

import Foundation

struct NutritionResponse: Codable {
    let id: Int
    let title: String
    let restaurantChain: String
    let nutrition: Nutrition
    let breadcrumbs: [String]
    let generatedText: String?
    let imageType: String?
    let likes: Int
    let price: Int?
}

struct Nutrition: Codable {
    let nutrients: [Nutrient]
    let caloricBreakdown: CaloricBreakdown
}

struct Nutrient: Codable {
    let name: String
    let amount: Int
    let unit: String
    let percentOfDailyNeeds: Int
}

struct CaloricBreakdown: Codable {
    let percentProtein: Int
    let percentFat: Int
    let percentCarbs: Int
}
