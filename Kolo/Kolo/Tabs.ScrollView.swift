//
//  Tabs.ScrollView.swift
//  Kolo
//
//  Created by Ivan Kh on 30.12.2021.
//

import AppKit

class TabsScrollView : NSScrollView {
    override var verticalScroller: NSScroller? {
        get { return nil }
        set {}
    }
}


class TabsCollectionView : NSCollectionView {
    override func setFrameSize(_ newSize: NSSize) {
        var modifiedSize = newSize
        modifiedSize.width = collectionViewLayout?.collectionViewContentSize.width ?? newSize.width
        super.setFrameSize(modifiedSize)
    }
}
