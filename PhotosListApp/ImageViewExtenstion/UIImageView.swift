//
//  UIImageView.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import UIKit

extension UIImageView {
    
    func imageFromURL(_ URLString: String?) {
        
        let image = UIImage(systemName: "photo")
        self.image = image
        
        guard let URLString = URLString else { return }
        let imageFromUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: imageFromUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                guard let data = data else {
                    print(error?.localizedDescription ?? "Error is unknown")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: invalid response")
                    return
                }
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data) {
                            self?.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
