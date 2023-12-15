//
//  ViewController.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 14.12.23.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Private Properties
    private var selectedId = 0
    
    //MARK: - Public Properties
    public var contentList = [ContentList]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ImageWithTitleTableViewCell.self, forCellReuseIdentifier: ImageWithTitleTableViewCell.identifier)
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
    
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] accessGranted in
            if !accessGranted {
                DispatchQueue.main.async {
                    self?.alertCameraAccessNeeded()
                }
            }
        }
    }
    
    private  func alertCameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsAppURL) else { return }
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to take pictures of item.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel) { _ in
            UIApplication.shared.open(settingsAppURL, options: [:])
        })
        present(alert, animated: true)
    }
}

// MARK: - extensions:
// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageWithTitleTableViewCell.identifier, for: indexPath) as! ImageWithTitleTableViewCell
        let content = contentList[indexPath.row]
        cell.configure(with: content)
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedId = indexPath.row
        
        let picker = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            requestCameraPermission()
            return
        case .authorized:
            break
        case .restricted, .denied:
            alertCameraAccessNeeded()
            return
        default:
            return
        }
        picker.sourceType = .camera
        present(picker, animated: true)
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
