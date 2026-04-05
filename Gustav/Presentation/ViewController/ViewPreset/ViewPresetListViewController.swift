//
//  ViewPresetListViewController.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//


import UIKit

final class ViewPresetListViewController: UIViewController {
    
    // MARK: - Properties
    private let rootView = ViewPresetListView()
    private let viewModel: ViewPresetListViewModel
    
    // Coordinator 연결용
    var onRoute: ((ViewPresetListViewModel.Route) -> Void)?
    
    // MARK: - Init
    init(viewModel: ViewPresetListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        bindViewModel()
        viewModel.action(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(.viewWillAppear)
    }
}

// MARK: - Setup
private extension ViewPresetListViewController {
    func setupNavigation() {
        
        
        navigationItem.title = "Preset"
        navigationItem.largeTitleDisplayMode = .always
       
        var subtitle = AttributedString("0 presets")
        // Large Title 하단에 표시되는 Large Subtitle 텍스트 설정
        subtitle.font = Fonts.accent
        subtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = subtitle
        // 스크롤 시 상단 Title 하단에 표시되는 Subtitle 텍스트 설정
        subtitle.font = Fonts.additional
        navigationItem.attributedSubtitle = subtitle

        
        // 좌측 뒤로가기 버튼
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        
        navigationItem.leftBarButtonItem = backButton
        
        // 우측 more (ellipsis) 버튼
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTapMore)
        )
        
        navigationItem.rightBarButtonItem = moreButton
        
        
        navigationController?.isToolbarHidden = false

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )

        toolbarItems = [UIBarButtonItem.flexibleSpace(), addButton]
    }
    
    func setupTableView() {
        rootView.configureTableView(delegate: self, dataSource: self)
    }
    
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.onRoute?(route)
        }
    }
    
    func apply(_ output: ViewPresetListViewModel.Output) {
        navigationItem.subtitle = "\(output.itemCount) presets"
        rootView.reloadList(count: output.itemCount)
        
        
        switch output.isLoading {
        case .loading(let message):
            rootView.loadingView.startLoading(with: message)
        case .notLoading:
            rootView.loadingView.stopLoading()
        }
    }
}

// MARK: - Action
private extension ViewPresetListViewController {
    @objc
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func didTapMore() {
        print("More tapped")
    }
    
    @objc
    func didTapAddButton() {
        viewModel.action(.didTapAddButton)
    }
}

// MARK: - UITableViewDataSource
extension ViewPresetListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ViewPresetListCellView.identifier,
            for: indexPath
        ) as? ViewPresetListCellView else {
            return UITableViewCell()
        }
        
        let item = viewModel.rowItem(at: indexPath.row)
        cell.configure(title: item.title, subtitle: item.subtitle)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewPresetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.action(.didSelectItem(at: indexPath.row))
    }
}
