//
//  Tabs.Controller.swift
//  Kolo
//
//  Created by Ivan Kh on 29.12.2021.
//

import AppKit


fileprivate extension NSUserInterfaceItemIdentifier {
    static let tabItem = NSUserInterfaceItemIdentifier("TabItem")
}


fileprivate extension NSNib.Name {
    static let tabItem = NSNib.Name("Tabs.Item")
}


class TabsController : NSViewController {
    @IBOutlet var collectionView: NSCollectionView!
    private var tabs = [URL?]()
    var tabSelected: ((Int) -> Void)?
    var navigate: ((String) -> Void)?
    var close: ((Int) -> Void)?
}


extension TabsController {
    var tabIndex: Int? {
        get {
            return collectionView.selectionIndexPaths.first?.item
        }
        set {
            if let newValue = newValue {
                let indexPath = IndexPath(item: newValue, section: 0)

                collectionView.selectionIndexPaths = [ indexPath ]
                collectionView.collectionViewLayout?.invalidateLayout()
            }
            else {
                collectionView.selectionIndexPaths = []
            }
        }
    }
    
    var tabURL: URL? {
        get {
            guard let tabIndex = tabIndex else { return nil }
            return tabs[tabIndex]
        }
        set {
            if let tabIndex = tabIndex {
                tabs[tabIndex] = newValue
            }
            
            tabItem?.url = newValue
        }
    }
    
    private var tabItem: TabsItem? {
        guard let tabIndex = tabIndex else { return nil }
        return collectionView.item(at: tabIndex) as? TabsItem
    }
    
    private var collectionViewLayout: TabsLayout {
        return collectionView.collectionViewLayout as! TabsLayout
    }
    
    @discardableResult func appendTab(_ url: URL?) -> Int {
        let indexPath = IndexPath(item: tabs.count, section: 0)
        
        guard let collectionView = tabs.count == 0 ? collectionView : collectionView.animator() else { return -1 }
        
        collectionView.performBatchUpdates {
            tabs.append(url)
            collectionView.insertItems(at: [ indexPath ])
        }

        (collectionView.firstSelectedItem as? TabsItem)?.isSelected = false
        (collectionView.item(at: indexPath) as? TabsItem)?.isSelected = true

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5

            collectionView.performBatchUpdates {
                collectionView.selectionIndexPaths = [ indexPath ]
            }
        }

        let width = self.collectionView.collectionViewLayout!.collectionViewContentSize.width
        self.collectionView.scroll(NSPoint(x: width, y: 0))
        
        return tabs.count - 1
    }
    
    func remove(tab index: Int) {
        guard let collectionView = tabs.count == 0 ? collectionView : collectionView.animator() else { return }
        let selectedIndex = tabIndex
        var makeFirstResponder = false

        let completionHandler = {
            if makeFirstResponder {
                self.view.window?.makeFirstResponder(self.tabItem?.input)
            }
        }
        
        if view.window?.firstResponder == tabItem?.input.currentEditor() {
            view.window?.makeFirstResponder(nil)
            makeFirstResponder = true
        }
        
        NSAnimationContext.runAnimationGroup({ context in

            collectionView.performBatchUpdates {
                tabs.remove(at: index)
                collectionView.deleteItems(at: [ IndexPath(item: index, section: 0) ])
            }

            if selectedIndex == index {
                collectionView.performBatchUpdates {
                    var nextIndex = index
                    
                    if nextIndex >= tabs.count {
                        nextIndex = index - 1
                    }
                    
                    if nextIndex >= 0 {
                        collectionView.selectionIndexPaths = [ IndexPath(item: nextIndex, section: 0) ]
                        tabSelected?(nextIndex)
                    }
                }
            }

        }, completionHandler: completionHandler)
    }
}


extension TabsController {
    private func navigate(urlString: String) {
        navigate?(urlString)
    }
    
    private func close(item: TabsItem) {
        guard let indexPath = item.collectionView?.indexPath(for: item) else { return }
        close?(indexPath.item)
    }
}


extension TabsController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nib = NSNib(nibNamed: .tabItem, bundle: nil) {
            collectionView.register(nib, forItemWithIdentifier: .tabItem)
        }
    }
}


extension TabsController : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.animator().performBatchUpdates(0.25, nil)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let indexPath = indexPaths.first {
            tabSelected?(indexPath.item)
        }
        
        collectionView.animator().performBatchUpdates(0.25, nil)
    }
}


extension TabsController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard
            let result = collectionView.makeItem(withIdentifier: .tabItem,
                                                 for: indexPath) as? TabsItem
        else {
            return NSCollectionViewItem()
        }
        
        result.url = tabs[indexPath.item]
        result.close = close(item:)
        result.navigate = navigate(urlString:)
        
        return result
    }
}
