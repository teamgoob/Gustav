//
//  LoadingView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/6.
//

import UIKit
import SnapKit

// MARK: - LoadingView
// 로딩 중 화면
final class LoadingView: UIView {
    // MARK: - UI Components
    // Loading Indicator
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Colors.Theme.primary
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    // 설명 텍스트
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.textColor = Colors.Text.main
        label.textAlignment = .center
        label.text = "Loading..."
        return label
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
        addSubview(loadingIndicator)
        addSubview(descriptionLabel)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(loadingIndicator.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    // MARK: - Visible / Animation Control
    func startLoading() {
        isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
        isHidden = true
    }
}

/* MARK: - Loading View 사용 방법
 
 // ~ View 파일
 
 // UI Components 선언
 let loadingView: LoadingView = {
     let view = LoadingView()
     // 안내 문구 설정
     view.descriptionLabel.text = "Loading Settings..."
     return view
 }()
 
 override init(frame: CGRect) {
     super.init(frame: frame)
     
     // 하위 뷰 추가
     addSubview(loadingView)
     // 제약 조건 설정
     loadingView.snp.makeConstraints {
         $0.edges.equalToSuperview()
     }
 }
 
 // ~ ViewController 파일
 
 // 로딩 상태에 따라 동작 결정
 if output.isLoading {
     customView.loadingView.startLoading()
 } else {
     customView.loadingView.stopLoading()
 }
 
 */
