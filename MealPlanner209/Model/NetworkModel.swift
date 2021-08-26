//
//  NetworkModel.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import Foundation
import Alamofire

class NetworkModel {
    
    static let APIKey = "058565b811424186affeb07aa849206c"
    
    enum EndPoints {
        static let base = "https://api.spoonacular.com/food/menuItems"
        static let apikey = "apiKey=\(NetworkModel.APIKey)"
        
        case searchFood(String, Int)
        case searchNutrients(Int)
            
        var stringValue: String {
            switch self {
            case .searchFood(let query, let page):
                return EndPoints.base + "/search?query=\(query)&number=10&offset=\(page)&" + EndPoints.apikey
            case .searchNutrients(let id):
                return EndPoints.base + "/\(id)?" + EndPoints.apikey
            }
        }
        var url: URL? {
            return URL(string: stringValue)
        }
    }
    
    class func getFoods(query: String, page: Int, completion: @escaping (FoodResponse?, Error?)->Void) -> DataRequest {
        let request = AF.request(EndPoints.searchFood(query, page).stringValue)
        request.responseJSON { (response) in
            print(String(data: response.data!, encoding: .utf8))
            switch response.result {
            case .success:
                guard let resultData = response.data else {
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(FoodResponse.self, from: resultData)
                    DispatchQueue.main.async {
                        print("Decode success")
                        completion(responseObject, nil)
                    }
                } catch {
                    print("Can't perform decode")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        return request
    }
    
    class func getNutrients(id: Int, completion: @escaping (NutritionResponse?, Error?)->Void) {
        AF.request(EndPoints.searchNutrients(id).stringValue).responseJSON { (response) in
            switch response.result {
            case.success:
                guard let resultData = response.data else { return }
                print(resultData)
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(NutritionResponse.self, from: resultData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    print("Can't perform decode")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            case.failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(needTrim: Bool, url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Data has a nil value")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData = data
            if needTrim {
                let range = (5..<data.count)
                newData = data.subdata(in: range)
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print("Cannot decode json data")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForRequest<RequestType: Encodable, ResponseType: Decodable>(needTrim: Bool, url: URL, method: String, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        if (method != "POST" && method != "PUT") {
            print("Invalid httpMethod")
            completion(nil, nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(body)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    print("Data has a nil value")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                var newData = data
                if needTrim {
                    let range = (5..<data.count)
                    newData = data.subdata(in: range)
                }
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    print("Disable to decode json file")
                }
            }
            task.resume()
        } catch {
            print("Disable to encode file")
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
}
