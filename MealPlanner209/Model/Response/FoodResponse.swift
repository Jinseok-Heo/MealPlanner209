//
//  FoodResponse.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/23.
//

import Foundation

struct FoodResponse: Codable {
    let menuItems: [MenuItem]
    let totalMenuItems: Int?
    let type: String?
    let offset: Int?
    let number: Int?
}

struct MenuItem: Codable {
    let id: Int?
    let title: String?
    let restarantChain: String?
    let image: String?
    let imageType: String?
    let servings: Serving?
}

struct Serving: Codable {
    let number: Int?
    let size: Int?
    let unit: String?
}

extension MenuItem {
    var imageURL: URL? {
        return URL(string: image ?? "")
    }
}
