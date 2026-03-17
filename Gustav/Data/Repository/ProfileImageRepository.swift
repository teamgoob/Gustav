//
//  ProfileImageRepository.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/17.
//

import Foundation

// MARK: - ProfileImageRepository
// ProfileImageRepository 구현체

final class ProfileImageRepository: ProfileImageRepositoryProtocol {
    // Supabase API 호출을 담당하는 remote datasource
    private let remote: ProfileImageDataSourceProtocol
    
    init(remote: ProfileImageDataSourceProtocol) {
        self.remote = remote
    }
    
    // 프로필 이미지 불러오기
    func fetchProfileImage(urlString: String?) async -> DomainResult<ProfileImage> {
        await remote.fetchProfileImage(urlString: urlString).toDomainResult()
    }
    
    // 프로필 이미지 업로드
    func uploadProfileImage(userId: String, data: Data) async -> DomainResult<ProfileImage> {
        await remote.uploadProfileImage(userId: userId, data: data).toDomainResult()
    }
    
    // 프로필 이미지 URL 업데이트
    func updateProfileImageUrl(userId: String, url: String?) async -> DomainResult<Void> {
        await remote.updateProfileImageUrl(userId: userId, url: url).toDomainResult()
    }
    
    // 프로필 이미지 및 URL 삭제
    func deleteProfileImage(userId: String) async -> DomainResult<Void> {
        await remote.deleteProfileImage(userId: userId).toDomainResult()
    }
}
