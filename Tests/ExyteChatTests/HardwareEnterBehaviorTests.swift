//
//  HardwareEnterBehaviorTests.swift
//  Chat
//
//  Created by Codex on 20/02/2026.
//

import SwiftUI
import Testing

@testable import ExyteChat

struct HardwareEnterBehaviorTests {
    typealias ConcreteChatView = ChatView<EmptyView, EmptyView, DefaultMessageMenuAction>

    @Test("Hardware Enter sends only when send behavior is enabled, input is focused, and the composer can send")
    func shouldSendOnHardwareEnterOnlyIfAllConditionsAreMet() {
        #expect(
            shouldSendOnHardwareEnter(
                for: .sendOnEnterShiftNewline,
                state: .hasTextOrMedia,
                isInputFocused: true,
                isSoftwareKeyboardVisible: false
            )
        )
    }

    @Test("Hardware Enter does not send when input is not focused")
    func shouldNotSendWhenInputIsNotFocused() {
        #expect(
            !shouldSendOnHardwareEnter(
                for: .sendOnEnterShiftNewline,
                state: .hasTextOrMedia,
                isInputFocused: false,
                isSoftwareKeyboardVisible: false
            )
        )
    }

    @Test("Hardware Enter does not send when composer cannot send")
    func shouldNotSendWhenComposerCannotSend() {
        #expect(
            !shouldSendOnHardwareEnter(
                for: .sendOnEnterShiftNewline,
                state: .empty,
                isInputFocused: true,
                isSoftwareKeyboardVisible: false
            )
        )
    }

    @Test("Hardware Enter does not send when behavior is insert newline")
    func shouldNotSendWhenBehaviorIsInsertNewline() {
        #expect(
            !shouldSendOnHardwareEnter(
                for: .insertNewline,
                state: .hasTextOrMedia,
                isInputFocused: true,
                isSoftwareKeyboardVisible: false
            )
        )
    }

    @Test("Hardware Enter does not send while software keyboard is visible")
    func shouldNotSendWhenSoftwareKeyboardIsVisible() {
        #expect(
            !shouldSendOnHardwareEnter(
                for: .sendOnEnterShiftNewline,
                state: .hasTextOrMedia,
                isInputFocused: true,
                isSoftwareKeyboardVisible: true
            )
        )
    }

    @Test("ChatView modifier sets hardware enter behavior used by all built-in input surfaces")
    func chatViewModifierSetsHardwareEnterBehavior() {
        let configured = makeChatView().setHardwareEnterBehavior(.sendOnEnterShiftNewline)
        #expect(configured.hardwareEnterBehavior == .sendOnEnterShiftNewline)
    }

    @MainActor
    @Test("Attachments editor carries the same hardware enter behavior for signature input")
    func attachmentsEditorCarriesHardwareEnterBehavior() {
        let editor = AttachmentsEditor<EmptyView>(
            inputViewModel: InputViewModel(),
            inputViewBuilder: nil,
            chatTitle: nil,
            messageStyler: AttributedString.init,
            orientationHandler: { _ in },
            mediaPickerSelectionParameters: nil,
            mediaPickerParameters: nil,
            availableInputs: [.text],
            hardwareEnterBehavior: .sendOnEnterShiftNewline,
            localization: createLocalization()
        )
        #expect(editor.hardwareEnterBehavior == .sendOnEnterShiftNewline)
    }

    private func makeChatView() -> ConcreteChatView {
        ConcreteChatView(
            messages: [],
            chatType: .conversation,
            replyMode: .quote,
            didSendMessage: { _ in },
            messageBuilder: { _, _, _, _, _, _, _, _ in
                EmptyView()
            },
            inputViewBuilder: { _, _, _, _, _, _ in
                EmptyView()
            },
            messageMenuAction: nil,
            localization: createLocalization()
        )
    }
}
