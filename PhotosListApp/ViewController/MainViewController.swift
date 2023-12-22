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
    private var getModel: GetModel?
    
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
        NetworkService.shared.fetchData { [weak self] model in
            if self?.getModel == nil {
                self?.getModel = model
            } else {
                self?.getModel?.content.append(contentsOf: model.content)
            }
            self?.tableView.reloadData()
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
    
    private func alertCameraNotFound() {
        let alert = UIAlertController(
            title: "Camera is not found",
            message: "Your device can not take photos without camera.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alert, animated: true)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = getModel, !model.content.isEmpty else { return 0}
        return (model.content.count / 20) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = getModel, !model.content.isEmpty else { return 0 }
        if model.totalPages - 1 == section {
            return model.content.count % 20
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let model = getModel else { return nil }
        return "Page \(section + 1) of \(model.totalPages)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = getModel, let contentItem = model.content[safe: indexForContent(at: indexPath)] else { return UITableViewCell()}
        if indexForContent(at: indexPath) == model.content.count - 1 {
            setUpInfo()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageWithTitleTableViewCell.identifier, for: indexPath) as! ImageWithTitleTableViewCell
        cell.configure(with: contentItem)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = getModel, let contentItem = model.content[safe: indexForContent(at: indexPath)] else { return }
        selectedId = contentItem.id
        
        guard let availableCaptureModes = UIImagePickerController.availableCaptureModes(for: .rear) as? [Int], availableCaptureModes.contains(0) else {
            alertCameraNotFound()
            return
        }
        
        let picker = UIImagePickerController()
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
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
        picker.delegate = self
        present(picker, animated: true)
    }
}

//MARK: - Helpers
private extension MainViewController {
    func indexForContent(at indexPath: IndexPath) -> Int {
        return indexPath.section * 20 + indexPath.row
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

