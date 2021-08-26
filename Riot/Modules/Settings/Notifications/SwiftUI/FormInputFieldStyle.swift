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

import Foundation
import SwiftUI

/**
 An input field for forms.
 */
@available(iOS 14.0, *)
struct FormInputFieldStyle: TextFieldStyle {
    
    @Environment(\.theme) var theme: Theme
    @Environment(\.isEnabled) var isEnabled
    
    private var textColor: Color {
        if !isEnabled {
            return Color(theme.colors.quarterlyContent)
        }
        return Color(theme.colors.primaryContent)
    }
    
    private var backgroundColor: Color {
        if !isEnabled && (theme is DarkTheme) {
            return Color(theme.colors.quinaryContent)
        }
        return Color(theme.colors.background)
    }
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .font(Font(theme.fonts.callout))
            .foregroundColor(textColor)
            .frame(minHeight: 48)
            .padding(.horizontal)
            .background(backgroundColor)
    }
}


@available(iOS 14.0, *)
struct FormInputFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VectorForm {
                TextField("Placeholder", text: .constant(""))
                    .textFieldStyle(FormInputFieldStyle())
                TextField("Placeholder", text: .constant("Web"))
                    .textFieldStyle(FormInputFieldStyle())
                TextField("Placeholder", text: .constant("Web"))
                    .textFieldStyle(FormInputFieldStyle())
                    .disabled(true)
                
            }
            .padding()
            VectorForm {
                TextField("Placeholder", text: .constant(""))
                    .textFieldStyle(FormInputFieldStyle())
                TextField("Placeholder", text: .constant("Web"))
                    .textFieldStyle(FormInputFieldStyle())
                TextField("Placeholder", text: .constant("Web"))
                    .textFieldStyle(FormInputFieldStyle())
                    .disabled(true)
                
            }
            .padding()
            .theme(ThemeIdentifier.dark)
        }

    }
}