//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import Foundation

final class LocationListViewModel {
    var onStateChange: ((State) -> Void)?
    var onNavigation: ((Route) -> Void)?

    private let selectedWorkspaceId: UUID
    private let locationUsecase: LocationUsecaseProtocol
    private var locationTask: Task<Void, Never>?

    private(set) var locations: [Location] = [] {
        didSet {
            emit(.subTitle(locationCountText()))
        }
    }

    private(set) var editingOrderLocations: [Location] = []

    enum State {
        case loading(Bool)
        case locationsChanged
        case subTitle(String)
    }

    enum Input {
        case dismiss
        case viewDidLoad
        case reFetchData
        case didTapAddButton
        case didTapreorderLocationButton
        case didReOrderLocation(at: Int, to: Int)
        case didSelectTapLocation(index: Int)
        case deleteLocation(index: Int)
    }

    enum Route {
        case dismiss
        case pushToLocationDetail(Location)
        case presentCreateLocation(Location)
        case showErrorAlert(String)
    }

    // MARK: - Deinit
    init(locationUsecase: LocationUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.locationUsecase = locationUsecase
        self.selectedWorkspaceId = selectedWorkspaceId
    }

    // MARK: - Deinit
    deinit {
        locationTask?.cancel()
        print("LoacationListViewModel deinit")
    }
    
    // 입력 처리
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            navigate(.dismiss)
        case .viewDidLoad:
            fetchLocations(showLoading: true)
        case .reFetchData:
            fetchLocations(showLoading: false)
        case .didTapAddButton:
            createLocation(name: "New Location")
        case .didTapreorderLocationButton:
            reorderLocations()
        case .didReOrderLocation(let from, let to):
            updateOrder(moveRowAt: from, to: to)
        case .didSelectTapLocation(let index):
            guard locations.indices.contains(index) else { return }
            navigate(.pushToLocationDetail(locations[index]))
        case .deleteLocation(let index):
            deleteLocation(at: index)
        }
    }

    // 작업 시작
    private func startTask(_ operation: @escaping () async -> Void) {
        locationTask?.cancel()
        locationTask = Task {
            await operation()
        }
    }

    // 상태 전달
    private func emit(_ state: State) {
        Task { @MainActor in
            self.onStateChange?(state)
        }
    }

    // 화면 이동
    private func navigate(_ route: Route) {
        Task { @MainActor in
            self.onNavigation?(route)
        }
    }

    // 개수 텍스트
    private func locationCountText() -> String {
        "\(locations.count) Locations"
    }

    // 목록 조회
    private func fetchLocations(showLoading: Bool) {
        startTask { [weak self] in
            guard let self else { return }

            if showLoading {
                self.emit(.loading(true))
            }
            defer {
                if showLoading {
                    self.emit(.loading(false))
                }
            }

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            let result = await self.locationUsecase.fetchLocations(workspaceId: self.selectedWorkspaceId)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let locations):
                self.locations = locations
                self.emit(.locationsChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 생성
    private func createLocation(name: String) {
        startTask { [weak self] in
            guard let self else { return }

            let newLocation = Location(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                indexKey: self.locations.count,
                name: name,
                color: .darkGray
            )

            let result = await self.locationUsecase.createLocation(
                workspaceId: self.selectedWorkspaceId,
                location: newLocation
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let location):
                self.locations.append(location)
                self.emit(.locationsChanged)
                self.navigate(.pushToLocationDetail(location))
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 순서 초안 저장
    func updateOrder(moveRowAt: Int, to: Int) {
        if editingOrderLocations.isEmpty {
            editingOrderLocations = locations
        }

        guard editingOrderLocations.indices.contains(moveRowAt) else { return }

        let movedItem = editingOrderLocations.remove(at: moveRowAt)
        let destination = min(to, editingOrderLocations.count)
        editingOrderLocations.insert(movedItem, at: destination)
    }

    // 순서 반영
    private func reorderLocations() {
        guard !editingOrderLocations.isEmpty else { return }

        startTask { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            defer { self.emit(.loading(false)) }

            let orderedIDs = self.editingOrderLocations.map(\.id)
            let draftLocations = self.editingOrderLocations.enumerated().map { index, location in
                Location(
                    id: location.id,
                    workspaceId: location.workspaceId,
                    indexKey: index,
                    name: location.name,
                    color: location.color
                )
            }

            let result = await self.locationUsecase.reorderLocations(
                workspaceId: self.selectedWorkspaceId,
                order: orderedIDs
            )

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            self.editingOrderLocations.removeAll()
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.locations = draftLocations
                self.emit(.locationsChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 삭제
    private func deleteLocation(at index: Int) {
        guard locations.indices.contains(index) else { return }
        let targetLocation = locations[index]

        startTask { [weak self] in
            guard let self else { return }

            let result = await self.locationUsecase.deleteLocation(
                id: targetLocation.id,
                workspaceId: self.selectedWorkspaceId
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.locations.remove(at: index)
                self.emit(.locationsChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 행 개수
    func numberOfRows() -> Int {
        locations.count
    }

    // 행 데이터
    func cellForRowAt(index: Int) -> Location {
        locations[index]
    }
}
