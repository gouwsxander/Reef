import Foundation
import SwiftUI

struct SwitcherItem: Identifiable, Equatable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
final class SwitcherViewModel: ObservableObject {
    @Published var title: String = "Select Window"
    @Published var items: [SwitcherItem] = []
    @Published var selectedIndex: Int = 0

    func setItems(_ newItems: [SwitcherItem]) {
        items = newItems
        selectedIndex = 0
    }

    func cycle() {
        guard !items.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % items.count
    }
}

func foobar() -> [SwitcherItem] {
    [
        SwitcherItem(title: "A Element"),
        SwitcherItem(title: "B Element"),
        SwitcherItem(title: "C Element")
    ]
}
