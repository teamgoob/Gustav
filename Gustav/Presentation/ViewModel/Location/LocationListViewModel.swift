//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//
import Foundation

final class LocationListViewModel {
    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // 워크스페이스 아이디
    private var selectedWorkspaceId: UUID
    
    // MARK: - Usecase
    private let locationUsecase: LocationUsecaseProtocol
    
    // Task Remote
    private var locationTask: Task<Void, Never>?

    // 기본 데이터
    private(set) var location: [Location] = [] {
        didSet {
            self.emit(.subTitle(locationCounting()))
        }
    }
    
    // 장소 순서 업데이트시 사용하는 프로퍼티
    private(set) var editingOrderLocation: [Location] = []
    
    // MARK: - init
    init(locationUsecase: LocationUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.locationUsecase = locationUsecase
        self.selectedWorkspaceId = selectedWorkspaceId
    }
    
    // MARK: - State(Output)
    enum State {
        case loading(Bool)      // 로딩 유무
        case success            // 단순 성공
        case subTitle(String)   // 서브타이틀
    }
    
    // MARK: - Input
    enum Input {
        case viewDidLoad                                        // viewDidLoad
        case reFetchData                                        // 카테고리 데이터 다시 불러오기
        case didTapAddButton                                    // Add
        case didTapreorderLocationButton                        // reorder 확정 버튼
        case didReOrderLocation(at: Int, to: Int)             // 순서 변경 중
        case didSelectTapLocation(index: Int)                   // select
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case pushToLocationDetail(Location)   // 워크스페이스 디테일한 화면 이동
        case presentCreateLocation(Location)             // 추후 생성 알럿을 코디네이터 역할로 변경시 사용
        case showErrorAlert(String)             // 에러 알럿창
    }
    
    
    // Action
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:      // ViewDidLoad
            fetchLocations()
        case .reFetchData:
            reFetchLocations()
        case .didTapAddButton:
            createLocation(name: "New Location")
            
        case .didTapreorderLocationButton:
            reorderLocation()
            
        case .didReOrderLocation(at: let from, to: let to):
            updateOrder(moveRowAt: from, to: to)
            
        case .didSelectTapLocation(let index):
            let location = location[index]
            onNavigation?(.pushToLocationDetail(location))
        }
    }
    
    // Fetch
    private func fetchLocations() {
        locationTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        locationTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조

            self.emit(.loading(true))       // 로딩 시작
            defer { self.emit(.loading(false) ) }    // 끝나면 로딩 끝
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            
            let result = await self.locationUsecase.fetchLocations(workspaceId: self.selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let location):
                self.location = location
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // reFetch
    private func reFetchLocations() {
        locationTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        locationTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조
            
            let result = await self.locationUsecase.fetchLocations(workspaceId: self.selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let location):
                self.location = location
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // Create
    private func createLocation(name: String) {
        print("Start createLocation task in LocationListViewModel")
        locationTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬
        locationTask = Task { [weak self] in
            guard let self else { return }
            
            let newLocation = Location(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                indexKey: self.location.count,
                name: name,
                color: TagColor.darkGray
            )
            let result = await self.locationUsecase.createLocation(workspaceId: self.selectedWorkspaceId, location: newLocation)
            switch result {
            case .success(let location):
                self.location.append(location)
                self.emit(.success)
                self.onNavigation?(.pushToLocationDetail(location))
            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // 워크스페이스 순서 변경 내용 임시 저장
    func updateOrder(moveRowAt : Int, to : Int) {
        if editingOrderLocation.isEmpty {
            self.editingOrderLocation = location
        }
        let movedItem = editingOrderLocation.remove(at: moveRowAt)
        editingOrderLocation.insert(movedItem, at: to)
    }
    
    // Reorder
    private func reorderLocation() {
        guard !editingOrderLocation.isEmpty else { return }
        
        locationTask?.cancel()
        locationTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            var draftLocation: [Location] = []
            var uuidArray: [UUID] = []
            var index: Int = 0
            
            for location in self.editingOrderLocation {
                draftLocation.append(
                    Location(
                        id: location.id,
                        workspaceId: location.workspaceId,
                        indexKey: index,
                        name: location.name,
                        color: location.color)
                )
                uuidArray.append(location.id)
                index += 1
            }
            
            let result = await self.locationUsecase.reorderLocations(workspaceId: self.selectedWorkspaceId, order: uuidArray)
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            self.emit(.loading(false) )
            switch result {
            case .success:
                self.location = draftLocation
                self.editingOrderLocation.removeAll()
                emit(.success)
            case .failure(let error):
                self.editingOrderLocation.removeAll()
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    private func locationCounting() -> String {
        return "\(location.count) Locations"
    }
    
    func numberOfRows() -> Int {
        location.count
    }
    func cellForRowAt(index: Int) -> Location {
        location[index]
    }
    
    private func cancel() {
        locationTask?.cancel()     // Task 객체에게 취소 플래그 전달
        locationTask = nil         // Task 객체는 누가 참조하지 않아도 존재 가능하며, 뷰모델에서는 참조 해제
    }

    // 갱신은 메인스레드에서
    @MainActor
    private func emit(_ state: State) {
        onStateChange?(state)
    }

    deinit {
        cancel()
        location.removeAll()
    }
}
