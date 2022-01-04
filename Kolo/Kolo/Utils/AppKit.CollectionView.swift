//
//  AppKit.CollecionView.swift
//  Kolo
//
//  Created by Ivan Kh on 04.01.2022.
//

import AppKit

extension NSCollectionView {
    var firstSelectedItem: NSCollectionViewItem? {
        guard let selectedIndexPath = selectionIndexPaths.first else { return nil }
        return item(at: selectedIndexPath)
    }
    
    func performBatchUpdates(_ duration: TimeInterval,
                             _ updates: (() -> Void)?,
                             completionHandler: ((Bool) -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            performBatchUpdates(updates, completionHandler: completionHandler)
        }
    }
}
