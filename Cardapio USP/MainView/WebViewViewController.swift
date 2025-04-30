//
//  WebViewViewController.swift
//  banner
//
//  Created by Vagner Machado on 16/04/25.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
