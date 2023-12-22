//
//  GetModel.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import Foundation

struct GetModel: Decodable {
    var content: [ContentList]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    
    mutating func addContent(of content: [ContentList]) {
        self.content.append(contentsOf: content)
    }
}

struct ContentList: Decodable {
    let id: Int
    let name: String
    let image: String?
}



