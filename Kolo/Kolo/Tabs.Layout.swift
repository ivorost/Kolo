//
//  Tabs.Layout.swift
//  Kolo
//
//  Created by Ivan Kh on 29.12.2021.
//

import AppKit


fileprivate extension CGFloat {
    static let space: CGFloat = 12
    static let minWidth: CGFloat = 50
    static let maxWidth: CGFloat = 150
    static let selectedMinWidth: CGFloat = 250
    static let selectedMaxWidth: CGFloat = 600
    static let paddingTop: CGFloat = 1
    static let paddingBottom: CGFloat = 1
    static let paddingLeft: CGFloat = 5
    static let paddingRight: CGFloat = 5
}


class TabsLayout: NSCollectionViewLayout {
        
    private var contentSize = CGSize.zero
    private var layoutAttributes = [IndexPath: NSCollectionViewLayoutAttributes]()
    
    override func prepare() {
        guard let collectionView = collectionView, let scrollView = collectionView.enclosingScrollView else { return }

        let count = collectionView.numberOfItems(inSection: 0)
        guard count != 0 else {
            contentSize = CGSize(width: 0, height: scrollView.frame.height)
            return
        }

        let spacesWidth = CGFloat(count - 1) * .space
        let availableWidth = scrollView.frame.width
        - CGFloat(count - 1) * (.maxWidth + .space)
        - .paddingRight
        - .paddingLeft
        let selectionWidth = min(max(availableWidth, .selectedMinWidth), .selectedMaxWidth)
        let freeWidth = ceil(scrollView.frame.width - selectionWidth - spacesWidth - .paddingRight - .paddingLeft)
        let calculatedWidth = count > 1 ? freeWidth / CGFloat(count - 1) : 0
        
        let width = max(min(calculatedWidth, .maxWidth), .minWidth)
        let cellSize = CGSize(width: width, height: scrollView.frame.height - .paddingBottom - .paddingTop)

        contentSize.width
        = cellSize.width * CGFloat(count - 1) + selectionWidth + spacesWidth + .paddingRight + .paddingLeft
       
        contentSize.height = scrollView.frame.height

        var origin = CGPoint(x: max(0, (scrollView.frame.width - contentSize.width) / 2.0) + .paddingLeft,
                             y: .paddingBottom)

        for index in 0 ..< count {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            var cellSize = cellSize
            
            if collectionView.selectionIndexPaths.contains(indexPath) {
                cellSize.width = selectionWidth
            }
            
            attributes.frame = CGRect(origin: origin, size: cellSize)
            layoutAttributes[indexPath] = attributes
            origin.x += cellSize.width + .space
        }

        contentSize.width = origin.x - .space + .paddingRight
        
        if contentSize.width < scrollView.frame.width {
            contentSize.width = scrollView.frame.width
        }
        
        if var documentViewFrame = collectionView.enclosingScrollView?.documentView?.frame {
            documentViewFrame.size = contentSize
            collectionView.enclosingScrollView?.documentView?.frame = documentViewFrame
        }
    }
    
    override var collectionViewContentSize: NSSize {
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return layoutAttributes.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
}
