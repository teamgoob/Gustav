//
//  WorkSpaceSelectionView.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

// MARK: - 워크스페이스 세팅
class LocationListView: UIView {

    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.separatorStyle = .singleLine
        tv.showsVerticalScrollIndicator = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = Colors.Theme.mainBackground
        tv.rowHeight = 50
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
        setAutoLayout()
    }
    
    private func setAutoLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
