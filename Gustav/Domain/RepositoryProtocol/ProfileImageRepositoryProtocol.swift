//
//  ProfileImageRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/17.
//

import Foundation

// MARK: - 프로필 이미지 Repository Protocol
protocol ProfileImageRepositoryProtocol {
    // 프로필 이미지 불러오기
    func fetchProfileImage(urlString: String?) async -> DomainResult<ProfileImage>
    // 프로필 이미지 업로드
    func uploadProfileImage(userId: UUID, data: Data) async -> DomainResult<ProfileImage>
    // 프로필 이미지 URL 업데이트
    func updateProfileImageUrl(userId: UUID, url: String?) async -> DomainResult<Void>
    // 프로필 이미지 및 URL 삭제
    func deleteProfileImage(userId: UUID) async -> DomainResult<Void>
}
