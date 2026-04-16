//
//  ProfileImageSupabase.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/17.
//

import Foundation
import Supabase

// MARK: - ProfileImageSupabase
// 프로필 이미지 원격 데이터소스 구현체
final class ProfileImageSupabase: ProfileImageDataSourceProtocol {
    private let client: SupabaseClient
    private let bucket = "profile-image"
    private let table = "profiles"
    
    // 외부에서 SupabaseClient 주입
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // 프로필 이미지 불러오기
    func fetchProfileImage(urlString: String?) async -> RepositoryResult<ProfileImageDTO> {
        guard let urlString, let url = URL(string: urlString) else {
            // URL이 없거나 잘못된 경우 빈 이미지 표시를 위해 nil DTO 반환
            return .success(ProfileImageDTO(data: nil, url: nil))
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // 결과 반환
            return .success(ProfileImageDTO(data: data, url: urlString))
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 프로필 이미지 업로드
    func uploadProfileImage(userId: UUID, data: Data) async -> RepositoryResult<ProfileImageDTO> {
        // 이미지 압축 + 리사이징
        guard let processedData = ImageProcessor.compress(data: data) else { return .failure(.unknown) }
        
        // 이미지 저장 경로 설정
        let path = "\(userId.uuidString.lowercased())/profile.jpg"
        
        do {
            // 설정한 경로에 이미지 덮어쓰기
            try await client.storage
                .from(bucket)
                .upload(
                    path,
                    data: processedData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
            // 이미지 URL 저장
            let url = try client.storage
                .from(bucket)
                .getPublicURL(path: path)
            
            // 이미지 데이터 + URL 반환
            return .success(ProfileImageDTO(data: processedData, url: url.absoluteString))
        }
        catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 프로필 이미지 URL 업데이트
    func updateProfileImageUrl(userId: UUID, url: String?) async -> RepositoryResult<Void> {
        do {
            // 사용자의 프로필 정보에서 프로필 이미지 URL 업데이트
            try await client
                .from(table)
                .update([
                    "profile_image_url" : url
                ])
                .eq("id", value: userId)
                .execute()
            
            return .success(())
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 프로필 이미지 및 URL 삭제
    func deleteProfileImage(userId: UUID) async -> RepositoryResult<Void> {
        // 이미지 저장 경로
        let path = "\(userId.uuidString.lowercased())/profile.jpg"
        
        do {
            // 이미지가 저장된 경로 삭제
            try await client.storage
                .from(bucket)
                .remove(paths: [path])
            
            // 사용자의 프로필 정보에서 이미지 URL 정보 삭제
            let updateResult = await self.updateProfileImageUrl(userId: userId, url: nil)
            
            switch updateResult {
            case .success:
                return .success(())
            case .failure(let error):
                // 에러 타입에 따라 Repository Error로 매핑하여 반환
                if let e = error as? RepositoryErrorConvertible {
                    return .failure(e.mapToRepositoryError())
                }
                
                return .failure(.unknown)
            }
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
}
