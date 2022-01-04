//
//  Tabs.ViewModel.swift
//  Kolo
//
//  Created by Ivan Kh on 30.12.2021.
//

import Foundation
import AppKit


class TabViewModel {
    private(set) var url: URL?
    private(set) var title: String?
    var controller: MainWebViewController?
    
    init(url: URL? = nil, controller: MainWebViewController? = nil) {
        self.url = url
        self.controller = controller
        self.title = url?.host
    }
    
    func load(url: URL) {
        update(url: url)
        controller?.load(url: url)
    }
    
    func update(url: URL) {
        self.url = url
        self.title = url.host
    }
}


extension TabViewModel {
    convenience init() {
        self.init(url: nil, controller: nil)
    }
    
    convenience init(controller: MainWebViewController) {
        self.init(url: nil, controller: controller)
    }
}
