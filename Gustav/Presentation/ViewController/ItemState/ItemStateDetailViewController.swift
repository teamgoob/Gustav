//
//  CategoryDetailViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/24/26.
//

import UIKit
import SnapKit

class ItemStateDetailViewController: UIViewController {
    private let contentView = ItemStateDetailView()
    private let loadingView = LoadingView()             // 로딩뷰
    private let viewModel: ItemStateDetailViewModel
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Init
    init(viewModel: ItemStateDetailViewModel) {
        self.viewModel = viewModel
        super .init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Deinit
    deinit { print("ItemStateDetailViewController deinit") }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()                   // 네비바 설정
        setUI()                     // 해당 뷰 관련 설정
        tableViewSetting()          // 테이블 뷰 설정
        collectionViewSetting()     // 컬렉션 뷰 설정
        bindViewModel()             // 뷰모델 연결
        viewModel.action(.viewDidLoad)  // 뷰모델 메서드 실행
    }
    
    
    
    private func setNavi() {
        // 네비게이션 타이틀 세팅
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = self.viewModel.getItemStateTitle()
        navigationItem.largeTitleDisplayMode = .always
        
        // 메뉴 생성
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: nil,
            action: nil
        )
        let menu = UIMenu(children: [
            UIAction(
                title: "Change Name",
                image: UIImage(systemName: "square.and.pencil")
            ) { [weak self] _ in
                guard let self else { return }
                print("Change Order")
                self.viewModel.action(.startChangeName)
            },
            UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                print("Delete")
                self.didTapDeleteButton()
            }
        ])
        menuButton.menu = menu
        navigationItem.rightBarButtonItems = [menuButton]
    }
    
    private func setUI() {
        // 기본 뷰 교체
        self.view = contentView
        
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loadingView.stopLoading()
    }
    
    private func bindViewModel() {
        // 데이터 관련
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .fetchedItems:
                self.contentView.tableView.reloadData()
            case .changeName(let name):
                self.title = name
            case .changeTagColor:
                self.contentView.collectionView.reloadData()
            case .delete:
                self.loadingView.startLoading()
                
            }
        }
    }
    
    // TableView Setting
    private func tableViewSetting() {
        // 대리자 등록
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        // 셀 등록
        contentView.tableView.register(
            ItemAttributeDetailItemCell.self,
            forCellReuseIdentifier: ItemAttributeDetailItemCell.reuseID
        )
    }
    
    // CollectionView Setting
    private func collectionViewSetting() {
        // 대리자 등록
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        
        // 셀 등록
        contentView.collectionView.register(
            TagColorCell.self,
            forCellWithReuseIdentifier: TagColorCell.reuseID
        )
    }
}

// MARK: - 버튼 메서드
extension ItemStateDetailViewController {
    
    private func didTapDeleteButton() {
        self.viewModel.action(.didTappedDeleteButton)
    }
}

// MARK: - Collection DataSource
extension ItemStateDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagColor: TagColor = self.viewModel.cellForItemAt(index: indexPath.row)
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TagColorCell.reuseID,
            for: indexPath
        ) as! TagColorCell
        
        let isSelected = (self.viewModel.getSelectedTagColor() == tagColor)
        cell.configure(cellColor: tagColor, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 32, height: 32)
    }
    
}

// MARK: - ColloectionView Delegate
extension ItemStateDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tagColor: TagColor = self.viewModel.cellForItemAt(index: indexPath.row)
        print("셀 눌림: \(tagColor.rawValue)")
        guard tagColor != self.viewModel.getSelectedTagColor() else { return }
        self.viewModel.action(.didChangeTagColor(tagColor))
        print("변경된 카테고리: \(tagColor.rawValue)")
        self.contentView.collectionView.reloadData()
    }
}

// MARK: - TableView DataSource
extension ItemStateDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.cellForRowAt(index: indexPath.row)

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemAttributeDetailItemCell.reuseID,
            for: indexPath
        ) as! ItemAttributeDetailItemCell
        
        cell.configure(title: item.name)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Associated Items"
    }
    
}

// MARK: - TableView Delegate
extension ItemStateDetailViewController: UITableViewDelegate {
    
}
