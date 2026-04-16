//
//  ImageProcessor.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/17.
//

import UIKit

// MARK: - 이미지 처리기
// Data Layer에서 UIKit 종속적인 기능이므로 별도의 타입으로 분리
enum ImageProcessor {
    // 이미지 압축 + 리사이징 메서드
    static func compress(data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxSize: CGFloat = 300
        let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized?.jpegData(compressionQuality: 0.6)
    }
}
