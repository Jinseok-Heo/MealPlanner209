//
//  SearchViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var currentPage: Int = 0
    var networkResult: FoodResponse?
    
    var currentNetworkTask: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search food"
        searchController.searchResultsUpdater = self

        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Search Food"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        currentPage += 1
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        if currentPage <= 1 {
            return
        }
        currentPage -= 1
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    private func getFoodCompletionHandler(result: FoodResponse?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription)
            return
        }
        guard let result = result else { return }
        self.networkResult = result
        self.tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index: \(indexPath.row) is tapped")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let result = networkResult {
            return result.menuItems.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        if let result = networkResult {
            let image = try? Data(contentsOf: result.menuItems[indexPath.row].imageURL!)
            guard let imageData = image else {
                return cell
            }
            guard let image = UIImage(data: imageData) else {
                return cell
            }
            cell.foodImageView.image = ImageHandler.resizeImage(image: image, targetSize: cell.foodImageView.frame.size)
            NetworkModel.getNutrients(id: result.menuItems[indexPath.row].id) { (result, error) in
                if let result = result {
                    let nutrients = result.nutrition.nutrients
                    for nutrient in nutrients {
                        var amount: Int = 0
                        if nutrient.unit == "g" {
                            amount = nutrient.amount * 4
                        } else {
                            amount = nutrient.amount
                        }
                        switch nutrient.name {
                        case "Calories":
                            cell.calories.text = String(amount)
                        case "Carbohydrates":
                            cell.carbs.text = String(amount)
                        case "Proteins":
                            cell.proteins.text = String(amount)
                        case "Fats":
                            cell.fats.text = String(amount)
                        default:
                            print("Other nutrients")
                        }
                    }
                }
            }
        }
        return cell
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.navigationItem.searchController!.searchBar.text else {
            return
        }
        print(text)
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: text, page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
}
