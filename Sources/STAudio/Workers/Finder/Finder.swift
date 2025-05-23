//  Created by Andrew Steellson on 03.05.2025.

import AppKit

@MainActor
public final class Finder {
    public enum Errors: Error {
        case selectionCancelled
        case savingCancelled
        case cantSelectWithURL
        case cantSaveFileWithURL
    }

    private let windowLevel = CGWindowLevelForKey(.modalPanelWindow)
    private var directoryURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appending(component: "Desktop")

    private let openPanel: NSOpenPanel
    private let savePanel: NSSavePanel

    public init() {
        openPanel = NSOpenPanel()
        savePanel = NSSavePanel()

        setup()
    }
}

// MARK: - Public
public extension Finder {
    /// Choose any file from your desktop
    func selectFile() async throws -> URL {
        guard await openPanel.begin() == .OK else {
            throw Errors.selectionCancelled
        }

        guard let url = openPanel.urls.first else {
            throw Errors.cantSelectWithURL
        }

        Log.info("Selected file url: \(url)")
        return url
    }
    
    /// Save file using dialog window
    /// - Parameters:
    ///   - name: File name
    /// - Returns: Saved file url address
    @discardableResult
    func saveFile(
        with name: String
    ) throws -> URL {
        NSApp.activate(ignoringOtherApps: true)
        savePanel.nameFieldStringValue = name

        let response = savePanel.runModal()
        guard response == .OK else {
            throw Errors.savingCancelled
        }

        guard let url = savePanel.url else {
            throw Errors.cantSaveFileWithURL
        }

        Log.success("File saved at \(url)")
        return url
    }
}

// MARK: - Private
private extension Finder {
    func setup() {
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.directoryURL = directoryURL
        savePanel.level = NSWindow.Level(
            rawValue: Int(windowLevel)
        )
    }
}
