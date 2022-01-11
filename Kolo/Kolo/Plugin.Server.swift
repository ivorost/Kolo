//
//  Plugin.Server.swift
//  Kolo
//
//  Created by Ivan Kh on 11.01.2022.
//

import Foundation
import GCDWebServers


extension UInt {
    static let defaultPort: UInt = 51232
}


class PluginServer : NSObject {
    static let shared = PluginServer()
    private let inner = GCDWebServer()
    private let queue = DispatchQueue.global()
    private var callback: ((URL) -> Void)?
    
    private override init() {
        super.init()
        inner.delegate = self
    }
    
    func startAsync(plugin: Plugin, callback: @escaping (URL) -> Void) {
        self.callback = callback
        
        queue.async {
            self.inner.removeAllHandlers()
            self.inner.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) { request in
                GCDWebServerFileResponse(file: plugin.url.appendingPathComponent(request.url.relativePath).path)
            }

            if !self.inner.isRunning {
                self.inner.start(withPort: .defaultPort, bonjourName: nil)
            }
            else {
                DispatchQueue.main.sync { self.doCallback() }
            }
        }
    }
    
    private func doCallback() {
        guard let url = inner.serverURL else { assertionFailure(); return }
        callback?(url)
    }
}


extension PluginServer : GCDWebServerDelegate {
    func webServerDidStart(_ server: GCDWebServer) {
        doCallback()
    }
}
