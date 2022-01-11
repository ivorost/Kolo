//
//  Utils.WebViewController.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import WebKit


class WebViewController: NSViewController {

    @IBOutlet private(set) var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSAppKitVersion.current.rawValue > 1500 {
            webView.setValue(false, forKey: "drawsBackground")
        }
        else {
            webView.setValue(true, forKey: "drawsTransparentBackground")
        }

        webView.uiDelegate = self
    }
}


extension WebViewController : WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {

        let alert = NSAlert()
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()

        completionHandler()
    }
}

extension WebViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("\(error)")
    }
}
