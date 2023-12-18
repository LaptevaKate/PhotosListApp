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
    
    //MARK: - Private Properties
    
    private let baseUrl = BaseURL.urlGetString.rawValue
    private let urlPost = BaseURL.urlPostString.rawValue
    private let name: String = "Lapteva Ekaterina"
    
    private init(){}
    
    //MARK: - Public Methods
    
    public func fetchData(completionHandler: @escaping(([ContentList]) -> Void)) {
        if let url = URL.init(string: baseUrl) {
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
    
    public func uploadPhoto(id: Int, image: UIImage){
        let url: String = urlPost
        guard let url: URL = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(name)\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(id)\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(name).jpeg\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let id = json?["id"] as? String {
                        print("Successfully uploaded photo with ID: \(id)")
                    } else {
                        print("Error: invalid response")
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("Error: invalid response")
            }
        }
        task.resume()
    }
}
