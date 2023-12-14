//
//  Extension.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import UIKit

extension UIImageView {
    
    func imageFromURL(_ URLString: String?) {
        let image = UIImage(systemName: "photo")
        let size = CGSize(width: 100, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image?.draw(in: CGRect(origin: .zero, size: size))
        let placeHolder = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = placeHolder
        guard let URLString = URLString else { return }
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: imageServerUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
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
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
