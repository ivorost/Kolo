//
//  PluginWebViewController.swift
//  Kolo
//
//  Created by Ivan Kh on 27.12.2021.
//

import WebKit


fileprivate extension String {
    static let jsTopSitesHandler = "topsites"
}


class PluginWebViewController : WebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.configuration.userContentController.add(self, name: .jsTopSitesHandler)

        jsUtility()
        jsTopSites()
    }
    
    private func jsUtility() {
        let js =
        """
        function dtid() {
            return "id" + (new Date()).getTime();
        }
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func jsTopSites() {
        let js =
        """
        var callback = function(){}
        var callbacks = {};
        
        callback.topsites = function(id, array) {
            callbacks[id](array);
            callbacks[id] = nil;
        }

        browser = function(){}
        browser.topSites = function(){}
        browser.topSites.get = function() {
            return new Promise( (resolutionFunc, rejectionFunc) => {
                var id = dtid();

                callbacks[id] = resolutionFunc;
                window.webkit.messageHandlers.topsites.postMessage({ "id": id });
            });
        }
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }

    private func jsTopSitesTest() {
        let js =
        """
        function logTopSites(topSitesArray) {
            alert(topSitesArray);
        }
        
        function onError(error) {
            console.log(error);
        }
        
        var gettingTopSites = browser.topSites.get();
        gettingTopSites.then(logTopSites, onError);
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }
}


extension PluginWebViewController {
    func load(_ plugin: Plugin) {
        _ = view
        webView.loadFileURL(plugin.htmlURL, allowingReadAccessTo: plugin.htmlURL.deletingLastPathComponent())
    }
}


extension PluginWebViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == .jsTopSitesHandler,
            let id = message.params["id"],
            let array = try? History.mostVisitedSites(NSManagedObjectContext.main) {
            let result = array.map { [ "url" : $0, "title" : $0 ] }
            let resultData = try! JSONEncoder().encode(result)
            let resultString = String(data: resultData, encoding: .utf8)!
            
            message.webView?.evaluateJavaScript("callback.topsites(\"\(id)\", \(resultString));", completionHandler: nil)
        }
    }
}
