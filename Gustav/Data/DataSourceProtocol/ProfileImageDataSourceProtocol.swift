//
//  ProfileImageDataSourceProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/17.
//

import Foundation

// MARK: - ProfileImageDataSourceProtocol
// 프로필 이미지 원격 데이터 소스 프로토콜
protocol ProfileImageDataSourceProtocol {
    // 프로필 이미지 불러오기
    func fetchProfileImage(urlString: String?) async -> RepositoryResult<ProfileImageDTO>
    // 프로필 이미지 업로드
    func uploadProfileImage(userId: String, data: Data) async -> RepositoryResult<ProfileImageDTO>
    // 프로필 이미지 URL 업데이트
    func updateProfileImageUrl(userId: String, url: String?) async -> RepositoryResult<Void>
    // 프로필 이미지 및 URL 삭제
    func deleteProfileImage(userId: String) async -> RepositoryResult<Void>
}
