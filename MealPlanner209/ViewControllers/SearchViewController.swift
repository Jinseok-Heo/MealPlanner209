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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentPage: Int = 1
    var networkResult: FoodResponse?
    
    var currentNetworkTask: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        previousButton.isEnabled = true
        nextButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let searchController = setupSearchController()
        setupNavigationItem(searchController: searchController)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        currentPage += 1
        currentNetworkTask?.cancel()
        setLoading(isLoading: true)
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        currentPage -= 1
        currentNetworkTask?.cancel()
        setLoading(isLoading: true)
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
    }
    
    private func getFoodCompletionHandler(result: FoodResponse?, error: Error?) {
        setLoading(isLoading: false)
        if error != nil { return }
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
        if let networkResult = networkResult {
            let image = try? Data(contentsOf: networkResult.menuItems[indexPath.row].imageURL!)
            guard let imageData = image else {
                return cell
            }
            guard let image = UIImage(data: imageData) else {
                return cell
            }
            cell.activityIndicator.startAnimating()
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
                    cell.activityIndicator.stopAnimating()
                } else {
                    DispatchQueue.main.async {
                        self.notifyMessage(message: "Can't get nutrients. Check network")
                    }
                }
            }
        }
        return cell
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if (self.navigationItem.searchController!.searchBar.text ?? "") == "" {
            return
        }
        currentNetworkTask?.cancel()
        currentNetworkTask = NetworkModel.getFoods(query: self.navigationItem.searchController!.searchBar.text ?? "", page: currentPage, completion: getFoodCompletionHandler(result:error:))
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
    
    private func setLoading(isLoading: Bool) {
        nextButton.isEnabled = !isLoading
        if isLoading {
            self.activityIndicator.startAnimating()
            previousButton.isEnabled = !isLoading
        } else {
            self.activityIndicator.stopAnimating()
            if currentPage > 1 {
                previousButton.isEnabled = !isLoading
            } else {
                previousButton.isEnabled = false
            }
        }
    }
    
    private func notifyMessage(message: String?=nil) {
        let alertController = UIAlertController(title: "Search failed", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
