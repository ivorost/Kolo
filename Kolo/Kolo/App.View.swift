//
//  ViewController.swift
//  Kolo
//
//  Created by Ivan Kh on 27.12.2021.
//

import AppKit


fileprivate extension NSStoryboardSegue.Identifier {
    static let showWebController = NSStoryboardSegue.Identifier("ShowWebController")
}


class WindowContentController : NSViewController {
    var webContentDidShow: ((MainWebViewController) -> Void)?
    private(set) var tabs = [TabViewModel]()
    @IBOutlet private(set) var webContainer: NSView!

    var tabsController: TabsController? {
        didSet {
            tabsController?.close = close(tab:)
        }
    }
}


extension WindowContentController {
    
    var currentTab: TabViewModel? {
        guard let tabIndex = tabsController?.tabIndex else { return nil }
        return tabs[tabIndex]
    }

    var webController: MainWebViewController? {
        return currentTab?.controller
    }
    
    private var visibleContent: MainWebViewController? {
        return tabs.first { $0.controller?.parent != nil }?.controller
    }
    
    func load(url: URL) {
        guard let tabIndex = tabsController?.tabIndex else { assertionFailure(); return }
        let tab = tabs[tabIndex]
        
        tab.load(url: url)
        tabsController?.tabURL = tab.url
    }
    
    func load(urlString: String) -> Bool {
        var mutableUrlString = urlString
        
        if !mutableUrlString.hasPrefix(.http) {
            mutableUrlString = "https://" + urlString
        }

        if let url = URL(string: mutableUrlString) {
            load(url: url)
            return true
        }
        else {
            return false
        }
    }

    func showCurrentTabContent() {
        guard let tab = currentTab else { assertionFailure(); return }
        
        hideVisibleContent()
        
        if let controller = tab.controller {
            addChild(controller)
            webContainer.addSubview(controller.view)
        }
        else {
            self.performSegue(withIdentifier: .showWebController, sender: self)
        }
    }
        
    @discardableResult func appendTab() -> TabViewModel {
        hideVisibleContent()
        let result = _appendTab()
        
        self.performSegue(withIdentifier: .showWebController, sender: self)
        
        return result
    }
    
    func closeTab() {
        if let tabIndex = tabsController?.tabIndex {
            close(tab: tabIndex)
        }
    }
}


extension WindowContentController {
    private func hide(controller: MainWebViewController) {
        let superview = controller.view.superview

        controller.removeFromParent()
        controller.view.removeFromSuperview()
        superview?.layout()
    }
    
    private func hideVisibleContent() {
        guard let controller = visibleContent else { return }
        hide(controller: controller)
    }

    private func hideContent(for tab: Int) {
        guard tabsController?.tabIndex == tab else { return }
        hideVisibleContent()
    }
    
    private func close(tab index: Int) {
        hideContent(for: index)
        tabs.remove(at: index)
        tabsController?.remove(tab: index)
    }
    
    private func _appendTab() -> TabViewModel {
        guard let tabsController = tabsController else { assertionFailure(); return TabViewModel() }
        let result = TabViewModel()
        
        tabs.append(result)
        tabsController.appendTab(result.url)
        
        return result
    }
}


extension WindowContentController {
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destinationController as? MainWebViewController {
            webContentDidShow?(destination)
            currentTab?.controller = destination
        }
    }
}
