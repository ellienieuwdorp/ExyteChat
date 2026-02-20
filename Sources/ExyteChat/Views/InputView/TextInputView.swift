//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct TextInputView: View {
    
    @Environment(\.chatTheme) private var theme
    
    @EnvironmentObject private var globalFocusState: GlobalFocusState
    
    @Binding var text: String
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization
    var onHardwareReturnKeyPress: (_ isShiftModified: Bool) -> Bool = { _ in false }
    
    var body: some View {
        #if targetEnvironment(macCatalyst)
        LegacyHardwareReturnTextInputView(
            text: $text,
            placeholder: style == .message ? localization.inputPlaceholder : localization.signatureText,
            textColor: UIColor(style == .message ? theme.colors.inputText : theme.colors.inputSignatureText),
            placeholderColor: UIColor(style == .message ? theme.colors.inputPlaceholderText : theme.colors.inputSignaturePlaceholderText),
            onHardwareReturnKeyPress: onHardwareReturnKeyPress
        )
        .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
        .padding(.vertical, 10)
        .padding(.leading, !isMediaAvailable() ? 12 : 0)
        .simultaneousGesture(
            TapGesture().onEnded {
                globalFocusState.focus = .uuid(inputFieldId)
            }
        )
        #else
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            TextField("", text: $text, prompt: Text(style == .message ? localization.inputPlaceholder : localization.signatureText)
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
                .onKeyPress(.return, phases: .down) { keyPress in
                    let modifiers = keyPress.modifiers
                    if modifiers != [] && modifiers != .shift {
                        // Prevent system submit behavior (e.g. Cmd+Enter stealing focus).
                        return .handled
                    }
                    if onHardwareReturnKeyPress(modifiers == .shift) {
                        return .handled
                    }
                    return .ignored
                }
        } else {
            #if canImport(UIKit)
            LegacyHardwareReturnTextInputView(
                text: $text,
                placeholder: style == .message ? localization.inputPlaceholder : localization.signatureText,
                textColor: UIColor(style == .message ? theme.colors.inputText : theme.colors.inputSignatureText),
                placeholderColor: UIColor(style == .message ? theme.colors.inputPlaceholderText : theme.colors.inputSignaturePlaceholderText),
                onHardwareReturnKeyPress: onHardwareReturnKeyPress
            )
            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
            .padding(.vertical, 10)
            .padding(.leading, !isMediaAvailable() ? 12 : 0)
            .simultaneousGesture(
                TapGesture().onEnded {
                    globalFocusState.focus = .uuid(inputFieldId)
                }
            )
            #else
            TextField("", text: $text, prompt: Text(style == .message ? localization.inputPlaceholder : localization.signatureText)
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
            #endif
        }
        #endif
    }
    
    private func isMediaAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.media)
    }
}

#if canImport(UIKit)
private struct LegacyHardwareReturnTextInputView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var textColor: UIColor
    var placeholderColor: UIColor
    var onHardwareReturnKeyPress: (_ isShiftModified: Bool) -> Bool
    
    func makeUIView(context: Context) -> LegacyHardwareReturnTextView {
        let textView = LegacyHardwareReturnTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.placeholder = placeholder
        textView.placeholderColor = placeholderColor
        textView.onHardwareReturnKeyPress = { onHardwareReturnKeyPress(false) }
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func updateUIView(_ uiView: LegacyHardwareReturnTextView, context: Context) {
        uiView.textColor = textColor
        uiView.placeholder = placeholder
        uiView.placeholderColor = placeholderColor
        uiView.onHardwareReturnKeyPress = { onHardwareReturnKeyPress(false) }
        if uiView.text != text {
            uiView.text = text
        }
        uiView.setNeedsDisplay()
        uiView.invalidateIntrinsicContentSize()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}

private extension LegacyHardwareReturnTextInputView {
    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            textView.invalidateIntrinsicContentSize()
            textView.setNeedsDisplay()
        }
    }
}

private final class LegacyHardwareReturnTextView: UITextView {
    var onHardwareReturnKeyPress: (() -> Bool)?
    var placeholder: String = ""
    var placeholderColor: UIColor = .placeholderText
    
    override var keyCommands: [UIKeyCommand]? {
        let returnKey = UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(handleReturnKey(_:)))
        returnKey.wantsPriorityOverSystemBehavior = true
        let commandReturnKey = UIKeyCommand(input: "\r", modifierFlags: [.command], action: #selector(handleModifiedReturn(_:)))
        commandReturnKey.wantsPriorityOverSystemBehavior = true
        return [returnKey, commandReturnKey]
    }
    
    override var intrinsicContentSize: CGSize {
        let fittingWidth = max(bounds.width, 1)
        let fittingSize = CGSize(width: fittingWidth, height: .greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
    }
    
    @objc
    private func handleReturnKey(_ sender: UIKeyCommand) {
        if onHardwareReturnKeyPress?() == true {
            return
        }
        insertText("\n")
    }
    
    @objc
    private func handleModifiedReturn(_ sender: UIKeyCommand) {
        // Ignore modified Return combos in legacy/catalyst path.
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard text.isEmpty else {
            return
        }
        let leftInset = textContainerInset.left + textContainer.lineFragmentPadding
        let topInset = textContainerInset.top
        let rightInset = textContainerInset.right + textContainer.lineFragmentPadding
        let placeholderRect = CGRect(
            x: leftInset + 2,
            y: topInset,
            width: rect.width - leftInset - rightInset - 4,
            height: rect.height - topInset - textContainerInset.bottom
        )
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: placeholderColor
        ]
        (placeholder as NSString).draw(in: placeholderRect, withAttributes: attributes)
    }
}
#endif
