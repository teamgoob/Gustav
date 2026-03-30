//
//  CategoryDetailView.swift
//  Gustav
//
//  Created by 박선린 on 3/24/26.
//

import UIKit
import SnapKit

class ItemStateDetailView: UIView {
    
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = Colors.Theme.mainBackground
        return v
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    // 테이블 뷰
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.separatorStyle = .singleLine
        tv.showsVerticalScrollIndicator = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = Colors.Theme.mainBackground
        tv.rowHeight = 40
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupTableHeaderView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUI() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTableHeaderView() {
        let headerHeight: CGFloat = 40
        
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: headerHeight
        )
        
        headerView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.tableHeaderView = headerView
    }
    
}
