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
    
    var currentPage: Int = 1
    var networkResult: FoodResponse?
    
    var currentNetworkTask: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchController = setupSearchController()
        setupNavigationItem(searchController: searchController)
        
        setupButton()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        currentPage += 1
        setupButton()
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        currentPage -= 1
        setupButton()
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    private func getFoodCompletionHandler(result: FoodResponse?, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
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
//            return result.menuItems.count
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        if let networkResult = networkResult {
            let image = try? Data(contentsOf: networkResult.menuItems[indexPath.row].imageURL!)
            guard let imageData = image else {
                return cell
            }
            guard let image = UIImage(data: imageData) else {
                return cell
            }
            cell.foodImageView.image = ImageHandler.resizeImage(image: image, targetSize: cell.foodImageView.frame.size)
            NetworkModel.getNutrients(id: networkResult.menuItems[indexPath.row].id!) { (result, error) in
                if let result = result {
                    guard let calories = result.nutrition!.calories else {
                        print("Calories has nil value")
                        return
                    } // Double
                    guard let carbs = result.nutrition!.carbs else {
                        print("Carbs has nil value")
                        return
                    } // String
                    guard let protein = result.nutrition!.protein else {
                        print("Proteins has nil value")
                        return
                    } // String
                    guard let fat = result.nutrition!.fat else {
                        print("Fats has nil value")
                        return
                    } // String
                    
                    cell.title.text = result.title ?? ""
                    cell.calories.text = "Calories: " + String(calories) + "kcal"
                    cell.carbs.text = "Carbs: " + carbs
                    cell.proteins.text = "Protein: " + protein
                    cell.fats.text = "Fat: " + fat
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
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: text, page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
}

extension SearchViewController {
    
    private func setupSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search food"
        searchController.searchResultsUpdater = self
        return searchController
    }
    
    private func setupNavigationItem(searchController: UISearchController) {
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Search"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.definesPresentationContext = true
    }
    
    private func setupButton() {
        if currentPage <= 1 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
    }
}
