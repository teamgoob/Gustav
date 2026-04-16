//
//  WebpageViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/11.
//

import UIKit
import WebKit

// MARK: - WebpageViewController
// WebView 표시를 위한 뷰 컨트롤러
// URL 및 페이지 제목을 입력하여 생성
final class WebpageViewController: UIViewController {
    // MARK: - Properties
    // 표시 URL
    private let urlString: String
    // 뷰
    private let customView = WebpageView()
    
    // MARK: - Initializer
    init(urlString: String, title: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        loadWebpage()
    }
}

// MARK: - Setup
private extension WebpageViewController {
    // 델리게이트 설정
    func setupDelegate() {
        customView.webView.navigationDelegate = self
    }
    
    // Webpage 로드
    func loadWebpage() {
        customView.load(with: urlString)
    }
}

// MARK: - WKNavigationDelegate
extension WebpageViewController: WKNavigationDelegate {
    // 로딩 중 구현
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        customView.loadingView.startLoading(with: "Loading page...")
    }
    // 로딩 완료 구현
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        customView.loadingView.stopLoading()
    }
}
