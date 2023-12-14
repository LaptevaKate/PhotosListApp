//
//  GetModel.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import Foundation

struct GetModel: Decodable {
    let content: [ContentList]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}

struct ContentList: Decodable {
    let id: Int
    let name: String
    let image: String?
}



