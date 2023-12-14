//
//  NetworkService.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import Foundation

class NetworkService {
    
    private let baseUrl = BaseURL.urlGetString.rawValue
    
    func fetchData(completionHandler: @escaping(([ContentList]) -> Void)) {
        
        if let urlToServer = URL.init(string: baseUrl){
            URLSession.shared.dataTask(with: urlToServer) { data, response, error in
                guard let data = data else {
                    print(error?.localizedDescription ?? "Unknown error")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(GetModel.self, from: data)
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
