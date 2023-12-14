//
//  ViewController.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var fetchData = NetworkService()
    var contentList = [ContentList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData.fetchData { items in
            self.contentList = items
        }
        tableView.dataSource = self

    }
    
    
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
    cell.textLabel?.text = self.contentList[indexPath.row].name
    
    return cell
    }
    

}

