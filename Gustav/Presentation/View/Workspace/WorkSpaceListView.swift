//
//  WorkSpaceSelectionView.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit
import Kingfisher
class WorkSpaceListView: UIView {
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    
    // MARK: - Header (사진 + 이름만)
    private lazy var headerView: UIView = {
        let header = UIView()
        header.backgroundColor = Colors.Theme.mainBackground

        profileImage.image = UIImage(systemName: "person.crop.circle")
        profileImage.backgroundColor = Colors.Theme.mainBackground
        profileImage.tintColor = Colors.Theme.inactive
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 60
        profileImage.clipsToBounds = true

        nameLabel.text = "Gustav"
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = Colors.Text.main

        header.addSubview(profileImage)
        header.addSubview(nameLabel)

        profileImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.size.equalTo(120)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }

        header.frame.size.height = 250

        return header
    }()
    
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = Colors.Theme.mainBackground
        return tv
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUI() {
        addSubview(tableView)
        tableView.tableHeaderView = headerView
        
        setAutoLayout()
    }
    
    private func setAutoLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    

    func updateProfile(imageUrl: String?, name: String) {
        nameLabel.text = name
        guard let urlString = imageUrl,
              let url = URL(string: urlString) else {

            profileImage.image = UIImage(systemName: "person.crop.circle.fill")
            return
        }

        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle.fill")
        )
    }
}
