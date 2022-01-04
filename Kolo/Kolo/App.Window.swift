//
//  WindowController.swift
//  Kolo
//
//  Created by Ivan Kh on 24.12.2021.
//

import AppKit


fileprivate extension NSToolbarItem.Identifier {
    static let plugin = NSToolbarItem.Identifier("Plugin")
}


fileprivate extension NSStoryboard.SceneIdentifier {
    static let tabs = NSStoryboard.SceneIdentifier("Tabs")
}


@objc class WindowController : NSWindowController {
    @IBOutlet private var pluginButton: NSToolbarItem!
    @IBOutlet private var tabsContainer: NSView!
    private var tabsController: TabsController?

    private(set) var plugin: Plugin? {
        didSet {
            DispatchQueue.main.async {
                guard let toolbar = self.window?.toolbar else { return }
                
                if (self.plugin != nil) {
                    let index = toolbar.items.count
                    toolbar.insertItem(withItemIdentifier: .plugin, at: index)
                }
                else if toolbar.items.last?.itemIdentifier == .plugin {
                    let index = toolbar.items.count - 1
                    toolbar.removeItem(at: index)
                }
            }
        }
    }
}


extension WindowController {
    var viewController: WindowContentController {
        return contentViewController as! WindowContentController
    }
}


extension WindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        if let screen = NSScreen.main {
            window?.setFrame(screen.visibleFrame, display: true)
            window?.backgroundColor = .koloWindowBackground
            window?.titlebarAppearsTransparent = true
        }
        
        plugin = Plugin.loadFirst()
        viewController.webContentDidShow = webContentDidShow(controller:)
        
        if let controller = viewController.webController {
            webContentDidShow(controller: controller)
        }
        
        if let tabsController = storyboard?.instantiateController(withIdentifier: .tabs) as? TabsController {
            tabsController.view.frame = tabsContainer.bounds
            tabsContainer.addSubview(tabsController.view)
            tabsController.tabSelected = tabSelected(index:)
            tabsController.navigate = navigate(urlString:)

            self.tabsController = tabsController
            viewController.tabsController = tabsController
        }

        viewController.appendTab()
        
        if let lastVisitedURL = Settings.shared.lastVisitedURL {
            viewController.load(url: lastVisitedURL)

            DispatchQueue.main.async {
                self.window?.makeFirstResponder(self.viewController.webController?.webView)
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let destination = segue.destinationController as? TabsController {
            destination.navigate = navigate(urlString:)
            self.tabsController = destination
            viewController.tabsController = destination
        }
    }
}


extension WindowController {
    private func webContentDidShow(controller: MainWebViewController) {
        controller.pluginDownloaded = downloaded(plugin:)
        controller.urlNavigated = navigated(to:)
    }

    private func navigate(urlString: String) {
        _ = viewController.load(urlString: urlString)
    }

    private func downloaded(plugin: Plugin) {
        self.plugin = plugin
    }

    private func navigated(to url: URL) {
        try! History.add(to: NSManagedObjectContext.main, url: url)
        
        if let currentTab = viewController.currentTab {
            currentTab.update(url: url)
            tabsController?.tabURL = currentTab.url
        }
    }
    
    private func tabSelected(index: Int) {
        viewController.showCurrentTabContent()
    }
}


extension WindowController {
    @IBAction func plusButtonAction(_ sender: Any) {
        viewController.appendTab()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        if let url = viewController.webController?.webView.backForwardList.backItem?.url {
            tabsController?.tabURL = url
        }
        
        viewController.webController?.webView.goBack()
    }
}
