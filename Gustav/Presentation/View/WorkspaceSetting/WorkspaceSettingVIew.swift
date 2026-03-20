//
//  WorkspaceSettingVIew.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/20.
//

import UIKit
import SnapKit

// MARK: - WorkspaceSettingView
// 워크스페이스 설정 화면
final class WorkspaceSettingView: UIView {
    // MARK: - Container
    // Content View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Setting List
    // Table View
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = true
        tableView.register(WorkspaceSettingTableCell.self, forCellReuseIdentifier: WorkspaceSettingTableCell.identifier)
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
        contentView.addSubview(tableView)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}
