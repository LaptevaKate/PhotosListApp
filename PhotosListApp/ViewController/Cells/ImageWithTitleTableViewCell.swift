//
//  ImageWithTitleTableViewCell.swift
//  PhotosListApp
//
//  Created by Екатерина Лаптева on 15.12.23.
//

import UIKit

final class ImageWithTitleTableViewCell: UITableViewCell {
    static let identifier = String(describing: ImageWithTitleTableViewCell.self)
    
    private lazy var cellTitleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cellImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellTitleLabel.text = nil
        cellImageView.image = nil
    }
    
    func configure(with content: ContentList) {
        cellTitleLabel.text = content.name
        let photoURL = content.image
        cellImageView.imageFromURL(photoURL)
    }
}

//MARK: - UI
private extension ImageWithTitleTableViewCell {
    func setupUI() {
        contentView.addSubview(cellTitleLabel)
        contentView.addSubview(cellImageView)
        
        let cellImageViewTopConstraint = cellImageView.heightAnchor.constraint(equalToConstant: 40)
        cellImageViewTopConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            cellImageViewTopConstraint,
            cellImageView.widthAnchor.constraint(equalToConstant: 40),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            cellTitleLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 10),
            cellTitleLabel.centerYAnchor.constraint(equalTo: cellImageView.centerYAnchor),
            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            
        ])
    }
}
