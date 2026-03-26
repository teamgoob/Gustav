//
//  WorkspaceView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit
import SnapKit

// MARK: - WorkspaceView
// 워크스페이스 화면 - 아이템 목록
final class WorkspaceView: UIView {
    // MARK: - Container
    // Content View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Item List
    // Table View
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.register(WorkspaceItemCell.self, forCellReuseIdentifier: WorkspaceItemCell.identifier)
        return tableView
    }()
    
    // MARK: - Loading View
    let loadingView: LoadingView = {
        let view = LoadingView()
        view.descriptionLabel.text = "Loading Items..."
        return view
    }()
    
    // MARK: - No Item Label
    let noItemLabel: UILabel = {
        let label = UILabel()
        label.text = "There's no items."
        label.font = Fonts.headline
        label.textColor = Colors.Text.main
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
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
        contentView.addSubview(noItemLabel)
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
        noItemLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
