//
//  App.View.Segue.swift
//  Kolo
//
//  Created by Ivan Kh on 04.01.2022.
//

import AppKit

class ShowWebViewSegue : NSStoryboardSegue {
    override func perform() {
        guard
            let src = sourceController as? WindowContentController,
            let dst = destinationController as? MainWebViewController
        else { return }

        dst.view.frame = src.webContainer.bounds
        dst.view.autoresizingMask = [ .width, .height ]
        src.addChild(dst)
        src.webContainer.addSubview(dst.view)
    }
}

