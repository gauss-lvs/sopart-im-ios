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

struct RoomRestrictedAccessSpaceChooserSelector: View {
    
    // MARK: Properties
    
    @ObservedObject var viewModel: MatrixItemChooserViewModel.Context
    let navTitle: String?
    
    // MARK: Private
    
    @Environment(\.theme) private var theme: ThemeSwiftUI

    @ViewBuilder
    var body: some View {
        MatrixItemChooser(viewModel: viewModel, listBottomPadding: nil)
            .background(theme.colors.background)
            .navigationTitle(VectorL10n.roomAccessSettingsScreenNavTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(VectorL10n.cancel) {
                        viewModel.send(viewAction: .cancel)
                    }
                    .foregroundColor(viewModel.viewState.loading ? theme.colors.quaternaryContent : theme.colors.accent)
                    .opacity(viewModel.viewState.loading ? 0.7 : 1)
                    .disabled(viewModel.viewState.loading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(VectorL10n.done) {
                        viewModel.send(viewAction: .done)
                    }
                    .foregroundColor(viewModel.viewState.selectedItemIds.isEmpty || viewModel.viewState.loading ? theme.colors.quaternaryContent : theme.colors.accent)
                    .opacity(viewModel.viewState.selectedItemIds.isEmpty || viewModel.viewState.loading ? 0.7 : 1)
                    .disabled(viewModel.viewState.selectedItemIds.isEmpty || viewModel.viewState.loading)
                }
            }
    }

}
