//
//  JSONDecoder+SupabaseDate.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let supabaseISO8601: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        let iso = ISO8601DateFormatter()
        if let d = iso.date(from: raw) { return d }

        let isoFrac = ISO8601DateFormatter()
        isoFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFrac.date(from: raw) { return d }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid date: \(raw)"
        )
    }
}

/*
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .supabaseISO8601
이 decoder를 SupabaseClient 생성할 때 넣는 방식
*/
