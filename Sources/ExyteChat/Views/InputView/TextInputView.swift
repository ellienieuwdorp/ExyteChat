//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
    
    @Environment(\.chatTheme) private var theme
    
    @EnvironmentObject private var globalFocusState: GlobalFocusState
    
    @Binding var text: String
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization
    var onSubmit: () -> Void = {}
    var onHardwareReturnKeyPress: (_ isShiftModified: Bool) -> Bool = { _ in false }
    
    var body: some View {
        let textField = TextField("", text: $text, prompt: Text(style == .message ? localization.inputPlaceholder : localization.signatureText)
            .foregroundColor(style == .message ? theme.colors.inputPlaceholderText : theme.colors.inputSignaturePlaceholderText), axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
            .foregroundColor(style == .message ? theme.colors.inputText : theme.colors.inputSignatureText)
            .padding(.vertical, 10)
            .padding(.leading, !isMediaAvailable() ? 12 : 0)
            .simultaneousGesture(
                TapGesture().onEnded {
                    globalFocusState.focus = .uuid(inputFieldId)
                }
            )

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            textField
                .onKeyPress(.return, phases: .down) { keyPress in
                    let modifiers = keyPress.modifiers
                    if modifiers != [] && modifiers != .shift {
                        return .ignored
                    }
                    if onHardwareReturnKeyPress(modifiers == .shift) {
                        return .handled
                    }
                    return .ignored
                }
        } else {
            textField
                .onSubmit(onSubmit)
        }
    }
    
    private func isMediaAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.media)
    }
}
