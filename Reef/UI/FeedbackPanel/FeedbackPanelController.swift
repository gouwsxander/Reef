//
//  FeedbackPanelController.swift
//  Reef
//

import AppKit

@MainActor
final class FeedbackPanelController {
    private let panel: CyclePanel
    private let iconView = NSImageView()
    private let messageLabel = NSTextField(labelWithString: "")
    private var hideTask: Task<Void, Never>?

    private let panelHeight: CGFloat = 64
    private let minPanelWidth: CGFloat = 220
    private let maxPanelWidth: CGFloat = 400
    private let horizontalPadding: CGFloat = 20
    private let iconSize: CGFloat = 32
    private let contentSpacing: CGFloat = 12

    init() {
        panel = CyclePanel(contentRect: NSRect(x: 0, y: 0, width: 220, height: 64))
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true

        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.setAccessibilityElement(false)

        messageLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        messageLabel.textColor = .white
        messageLabel.lineBreakMode = .byTruncatingTail

        let contentStack = NSStackView(views: [iconView, messageLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.orientation = .horizontal
        contentStack.alignment = .centerY
        contentStack.spacing = contentSpacing

        guard let contentView = panel.contentView else { return }
        contentView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            contentStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }

    func show(_ message: String, icon: NSImage? = nil) {
        hideTask?.cancel()
        iconView.image = icon
        iconView.isHidden = icon == nil
        messageLabel.stringValue = message
        messageLabel.alignment = icon == nil ? .center : .left
        let iconWidth = icon == nil ? 0 : iconSize + contentSpacing
        let desiredWidth = (horizontalPadding * 2) + iconWidth + messageLabel.intrinsicContentSize.width
        let panelWidth = min(max(desiredWidth.rounded(.up), minPanelWidth), maxPanelWidth)
        panel.setContentSize(NSSize(width: panelWidth, height: panelHeight))
        panel.center()
        panel.orderFrontRegardless()

        hideTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000)
            } catch {
                return
            }

            self?.panel.orderOut(nil)
        }
    }
}
