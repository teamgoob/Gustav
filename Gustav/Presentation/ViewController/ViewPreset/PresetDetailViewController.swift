//
//  PresetDetailViewController.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation

//
//  PresetDetailViewController.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit

// MARK: - PresetDetailViewController
final class PresetDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let rootView = PresetDetailView()
    private let viewModel: PresetDetailViewModel
    
    // Coordinator 연결용
    var onRoute: ((PresetDetailViewModel.Route) -> Void)?
    
    // MARK: - Init
    init(viewModel: PresetDetailViewModel) {
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
        bindViewModel()
        bindActions()
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension PresetDetailViewController {
    
    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = ""

        // 이전 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )

        // ellipsis 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTapMore)
        )
    }
    
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.onRoute?(route)
        }
    }
    
    func bindActions() {
        rootView.viewTypeRow.addTarget(self, action: #selector(didTapViewType), for: .touchUpInside)
        rootView.sortByRow.addTarget(self, action: #selector(didTapSortBy), for: .touchUpInside)
        rootView.sortOrderRow.addTarget(self, action: #selector(didTapSortOrder), for: .touchUpInside)
        rootView.categoryRow.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        rootView.locationRow.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        rootView.itemStatusRow.addTarget(self, action: #selector(didTapItemStatus), for: .touchUpInside)
    }
}

// MARK: - Render
private extension PresetDetailViewController {
    
    func apply(_ output: PresetDetailViewModel.Output) {
        navigationItem.title = output.title

        rootView.configure(
            viewType: output.viewType,
            sortingOption: output.sortingOption,
            sortingOrder: output.sortingOrder,
            category: output.category,
            location: output.location,
            itemStatus: output.itemStatus
        )
    }
}

// MARK: - Actions
private extension PresetDetailViewController {
    
    @objc func didTapViewType() {
        viewModel.action(.didTapViewType)
    }
    
    @objc func didTapSortBy() {
        viewModel.action(.didTapSortBy)
    }
    
    @objc func didTapSortOrder() {
        viewModel.action(.didTapSortOrder)
    }
    
    @objc func didTapCategory() {
        viewModel.action(.didTapCategory)
    }
    
    @objc func didTapLocation() {
        viewModel.action(.didTapLocation)
    }
    
    @objc func didTapItemStatus() {
        viewModel.action(.didTapItemStatus)
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func didTapMore() {
        viewModel.action(.didTapMore)
    }
}
