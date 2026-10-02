import AppKit

@main
enum LiquidGlassCocoaMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        // NSApplication.delegate is weak — keep a strong reference for the process lifetime.
        AppDelegate.shared = delegate
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMainMenu()

        let window: NSWindow
        if #available(macOS 26.0, *) {
            let playground = PlaygroundViewController()
            window = NSWindow(contentViewController: playground)
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.title = "Liquid Glass Cocoa"
            window.setContentSize(NSSize(width: 1120, height: 740))
            window.minSize = NSSize(width: 920, height: 620)
        } else {
            let label = NSTextField(labelWithString: "Liquid Glass requires macOS 26 and Xcode 26+.")
            label.alignment = .center
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 200),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.contentView = label
            window.title = "Liquid Glass Cocoa"
        }

        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "About Liquid Glass",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "Quit Liquid Glass",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenuItem.submenu = appMenu

        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenuItem.submenu = windowMenu
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }
}
