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

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("ViewPresetListView") {
    PreviewContainerView()
}

@available(iOS 17.0, *)
private struct PreviewContainerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Colors.Theme.mainBackground
        
        let view = ViewPresetListView()
        let dataSource = context.coordinator
        view.configureTableView(delegate: dataSource, dataSource: dataSource)
        view.reloadList(count: dataSource.items.count)
        
        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> PreviewDataSource {
        PreviewDataSource()
    }
}

@available(iOS 17.0, *)
private final class PreviewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let items: [(title: String, subtitle: String)] = [
        ("애플 신제품", "2026.03.19 최초 저장"),
        ("삼성 신제품", "2026.03.18 최초 저장"),
        ("애플 중고", "2026.03.17 최초 저장"),
        ("삼성 중고", "2026.03.16 최초 저장"),
        ("삼성 중고2", "2026.03.16 최초 저장")
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ViewPresetListCellView.identifier,
            for: indexPath
        ) as? ViewPresetListCellView else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle)
        return cell
    }
}
#endif
