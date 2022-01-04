//
//  App.Window.Segue.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import AppKit


class ShowPluginSegue : NSStoryboardSegue {
    override func perform() {
        guard
            let src = sourceController as? WindowController,
            let dst = destinationController as? PluginWebViewController,
            let plugin = src.plugin
        else { return }
        
        dst.load(plugin)
        
        super.perform()
    }
}

