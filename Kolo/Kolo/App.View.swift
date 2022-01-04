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
    var tabsController: TabsController?
    private(set) var tabs = [TabViewModel]()
    @IBOutlet private(set) var webContainer: NSView!
}


extension WindowContentController {
    
    var currentTab: TabViewModel? {
        guard let tabsController = tabsController else { return nil }
        return tabs[tabsController.tabIndex]
    }

    var webController: MainWebViewController? {
        return currentTab?.controller
    }
    
    private var visibleContent: MainWebViewController? {
        return tabs.first { $0.controller?.parent != nil }?.controller
    }
    
    func load(url: URL) {
        guard let tabsController = tabsController else { assertionFailure(); return }
        let tab = tabs[tabsController.tabIndex]
        
        tab.load(url: url)
        tabsController.tabURL = tab.url
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
    
    @discardableResult func appendTab() -> TabViewModel {
        hideVisibleContent()
        let result = _appendTab()
        
        self.performSegue(withIdentifier: .showWebController, sender: self)
        
        return result
    }
    
    @discardableResult private func _appendTab() -> TabViewModel {
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
