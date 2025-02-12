//
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

enum SpaceSelectorBottomSheetCoordinatorResult {
    case cancel
    case homeSelected
    case spaceSelected(_ item: SpaceSelectorListItemData)
    case createSpace(_ parentSpaceId: String?)
}

struct SpaceSelectorBottomSheetCoordinatorParameters {
    let session: MXSession
    let selectedSpaceId: String?
    let showHomeSpace: Bool
    
    init(session: MXSession,
         selectedSpaceId: String? = nil,
         showHomeSpace: Bool = false) {
        self.session = session
        self.selectedSpaceId = selectedSpaceId
        self.showHomeSpace = showHomeSpace
    }
}

final class SpaceSelectorBottomSheetCoordinator: Coordinator, Presentable {
    
    // MARK: - Properties
    
    private let parameters: SpaceSelectorBottomSheetCoordinatorParameters
    
    private let navigationRouter: NavigationRouterType
    private var spaceIdStack: [String]
    
    private weak var roomDetailCoordinator: SpaceChildRoomDetailCoordinator?
    private weak var currentSpaceSelectorCoordinator: SpaceSelectorCoordinator?

    // MARK: - Public

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    var completion: ((SpaceSelectorBottomSheetCoordinatorResult) -> Void)?
    
    // MARK: - Setup
    
    init(parameters: SpaceSelectorBottomSheetCoordinatorParameters,
         navigationRouter: NavigationRouterType = NavigationRouter(navigationController: RiotNavigationController())) {
        self.parameters = parameters
        self.navigationRouter = navigationRouter
        self.spaceIdStack = []
        self.setupNavigationRouter()
    }
    
    // MARK: - Public
    
    func start() {
        pushSpace(withId: nil)
    }
    
    func toPresentable() -> UIViewController {
        return self.navigationRouter.toPresentable()
    }
    
    // MARK: - Private
    
    private func setupNavigationRouter() {
        guard #available(iOS 15.0, *) else { return }
        
        guard let sheetController = self.navigationRouter.toPresentable().sheetPresentationController else {
            MXLog.debug("[SpaceSelectorBottomSheetCoordinator] setup: no sheetPresentationController found")
            return
        }
        
        sheetController.detents = [.medium(), .large()]
        sheetController.prefersGrabberVisible = true
        sheetController.selectedDetentIdentifier = .medium
        sheetController.prefersScrollingExpandsWhenScrolledToEdge = true
    }

    private func createSpaceSelectorCoordinator(parentSpaceId: String?) -> SpaceSelectorCoordinator {
        let parameters = SpaceSelectorCoordinatorParameters(session: parameters.session,
                                                            parentSpaceId: parentSpaceId,
                                                            selectedSpaceId: parameters.selectedSpaceId,
                                                            showHomeSpace: parameters.showHomeSpace,
                                                            showCancel: navigationRouter.modules.isEmpty)
        let coordinator = SpaceSelectorCoordinator(parameters: parameters)
        coordinator.completion = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .cancel:
                self.completion?(.cancel)
            case .homeSelected:
                self.trackSpaceSelection(with: nil)
                self.completion?(.homeSelected)
            case .spaceSelected(let item):
                self.trackSpaceSelection(with: item.id)
                self.completion?(.spaceSelected(item))
            case .spaceDisclosure(let item):
                self.pushSpace(withId: item.id)
            case .createSpace(let parentSpaceId):
                self.completion?(.createSpace(parentSpaceId))
            }
        }
        
        return coordinator
    }

    private func pushSpace(withId spaceId: String?) {
        let coordinator = self.createSpaceSelectorCoordinator(parentSpaceId: spaceId)
        
        coordinator.start()
        
        self.add(childCoordinator: coordinator)
        self.currentSpaceSelectorCoordinator = coordinator

        if let spaceId = spaceId {
            self.spaceIdStack.append(spaceId)
        }

        if self.navigationRouter.modules.isEmpty {
            self.navigationRouter.setRootModule(coordinator)
        } else {
            self.navigationRouter.push(coordinator.toPresentable(), animated: true) {
                self.remove(childCoordinator: coordinator)
                self.spaceIdStack.removeLast()
            }
        }
    }
    
    private func trackSpaceSelection(with spaceId: String?) {
        guard parameters.selectedSpaceId != spaceId else {
            Analytics.shared.trackInteraction(.spacePanelSelectedSpace)
            return
        }
        
        Analytics.shared.trackInteraction(.spacePanelSwitchSpace)
    }
}
