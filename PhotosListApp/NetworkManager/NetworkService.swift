//
//  NetworkService.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import Foundation
import UIKit

class NetworkService {
    
    static let shared = NetworkService()
    private let baseUrl = BaseURL.urlGetString.rawValue
    
    private init(){}
    
    func fetchData(completionHandler: @escaping(([ContentList]) -> Void)) {
        if let url = URL.init(string: baseUrl){
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print(error?.localizedDescription ?? "Error is unknown")
                    return
                }
                do {
                    let result = try JSONDecoder().decode(GetModel.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(result.content)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
    

}
