//
//  WebViewViewController.swift
//  banner
//
//  Created by Vagner Machado on 16/04/25.
//

import UIKit
import WebKit
import SVProgressHUD

class WebViewViewController: UIViewController, WKNavigationDelegate {
  var urlString: String?
  private var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    webView = WKWebView(frame: view.bounds)
    webView.navigationDelegate = self
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(webView)
    
    if let urlString = urlString, let url = URL(string: urlString) {
      let request = URLRequest(url: url)
      SVProgressHUD.show()
      webView.load(request)
    }
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    SVProgressHUD.dismiss()
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    SVProgressHUD.dismiss()
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    SVProgressHUD.dismiss()
  }
}
