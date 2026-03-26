//
//  AppSettingView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/3.
//

import UIKit
import SnapKit

// MARK: - AppSettingView
// 앱 설정 화면
final class AppSettingView: UIView {
    // MARK: - Container
    // Content View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Profile
    // Profile Image
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle,fill")
        imageView.tintColor = Colors.Theme.inactive
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // User Name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.headline
        label.textColor = Colors.Text.main
        label.textAlignment = .center
        label.text = "Gustav"
        return label
    }()
    
    // User Email
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.textColor = Colors.Text.additionalInfo
        label.textAlignment = .center
        label.text = "gustav@sample.com"
        return label
    }()
    
    // MARK: - Setting List
    // Table View
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AppSettingTableCell.self, forCellReuseIdentifier: AppSettingTableCell.identifier)
        return tableView
    }()
    
    // MARK: - Loading View
    let loadingView: LoadingView = {
        let view = LoadingView()
        view.descriptionLabel.text = "Loading Settings..."
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        loadingView.stopLoading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        backgroundColor = Colors.Theme.mainBackground
        addSubview(contentView)
        addSubview(loadingView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(tableView)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
