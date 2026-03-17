//
//  ProfileDTO.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

struct ProfileDTO: Decodable {
    let id: UUID
    let name: String?
    let email: String?
    let isPrivateEmail: Bool
    let createdAt: Date
    let updatedAt: Date
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case isPrivateEmail = "is_private_email"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profileImageUrl = "profile_image_url"
    }
}
