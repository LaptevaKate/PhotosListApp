//
//  ViewController.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Private Properties
    private var selectedId = 0
    
    //MARK: - Public Properties
    public var contentList = [ContentList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setUpInfo()
        
    }
    
    // MARK: - Method
    
    private func setUpInfo() {
        NetworkService.shared.fetchData { items in
            self.contentList = items
            self.tableView.reloadData()
        }
    }
}

// MARK: - extensions
// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        cell.textLabel?.text = self.contentList[indexPath.row].name
        let photoURL = contentList[indexPath.row].image
        cell.imageView?.imageFromURL(photoURL)
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == contentList.count - 1 {
            setUpInfo()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = indexPath.row
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}
// MARK: - UIImagePickerControllerDelegate
extension MainViewController:  UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            NetworkService.shared.uploadPhoto(id: selectedId, image: image)
        }
    }
}
