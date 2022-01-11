//
//  ViewController.swift
//  Kolo
//
//  Created by Ivan Kh on 23.12.2021.
//

import Cocoa
import WebKit
import ZIPFoundation


class MainWebViewController: WebViewController {

    var pluginDownloaded: ((Plugin) -> Void)?
    var urlNavigated: ((URL) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0"

        jsRenameBrowser()
    }
}


extension MainWebViewController {
    func load(url: URL) {
        Settings.shared.lastVisitedURL = url
        webView.load(URLRequest(url: url))
    }
}


extension MainWebViewController {
    private func jsRenameBrowser() {
        let js =
        """
        var elements = document.getElementsByClassName("AMInstallButton-button");
        var first = elements[0];

        first.innerHTML = "Add to Orion";
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }

    private func download(plugin remoteURL: URL) {
        Plugin.download(src: remoteURL) { [weak self] plugin, error in
            if let plugin = plugin {
                self?.pluginDownloaded?(plugin)
            }
            else if let error = error {
                assertionFailure("\(error)")
            }
            else {
                assertionFailure()
            }
        }
    }
}


extension MainWebViewController /* WKNavigationDelegate */ {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, url.isTopSiteButtonURL {
            decisionHandler(.cancel)
            download(plugin: url)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url {
            Settings.shared.lastVisitedURL = url
            urlNavigated?(url)
        }
    }
}


