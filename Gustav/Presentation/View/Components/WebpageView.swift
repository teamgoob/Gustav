//
//  WebpageView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/11.
//

import UIKit
import WebKit
import SnapKit

// MARK: - WebpageView
// WebView 표시를 위한 커스텀 뷰, 로딩 상태 구현
final class WebpageView: UIView {
    // MARK: - UI Components
    // WebView
    let webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    // MARK: - Loading View
    let loadingView: LoadingView = {
        let view = LoadingView()
        view.descriptionLabel.text = "Loading Page..."
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        backgroundColor = Colors.Theme.mainBackground
        addSubview(webView)
        addSubview(loadingView)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - 외부 호출 메서드
extension WebpageView {
    // Webpage 로드
    func load(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
