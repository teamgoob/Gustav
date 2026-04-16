//
//  PresetListView.swift
//  Gustav
//
//  Created by kaeun on 3/19/26.
//
import UIKit
import SnapKit

// 타이틀과 아이템 추가 버튼은 네비게이션으로 사용할 예정

final class ViewPresetListView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // UI Components 선언
    let loadingView: LoadingView = {
        let view = LoadingView()
        // 안내 문구 설정
        view.descriptionLabel.text = "Loading Preset List..."
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupStyle()
        loadingView.stopLoading()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(tableView)
        addSubview(loadingView)
        
        tableView.sectionHeaderTopPadding = 0
        tableView.register(ViewPresetListCellView.self, forCellReuseIdentifier: ViewPresetListCellView.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupStyle() {
        backgroundColor = Colors.Theme.mainBackground
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = 60
        tableView.showsVerticalScrollIndicator = false
    }
    
    func configureTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
    
    func reloadList(count: Int) {
        tableView.reloadData()
    }
}

