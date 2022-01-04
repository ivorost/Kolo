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
}


extension TabsController {
    var tabIndex: Int {
        get {
            return collectionView.selectionIndexPaths.first?.item ?? 0
        }
        set {
            let indexPath = IndexPath(item: newValue, section: 0)

            collectionView.selectionIndexPaths = [ indexPath ]
            collectionView.collectionViewLayout?.invalidateLayout()
        }
    }
    
    var tabURL: URL? {
        get {
            return tabs[tabIndex]
        }
        set {
            tabs[tabIndex] = newValue
            (collectionView.item(at: tabIndex) as? TabsItem)?.url = newValue
        }
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
    
    private func navigate(urlString: String) {
        navigate?(urlString)
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
        result.navigate = navigate(urlString:)
        
        return result
    }
}
