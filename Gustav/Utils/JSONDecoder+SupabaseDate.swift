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

        let localISO = DateFormatter()
        localISO.calendar = Calendar(identifier: .iso8601)
        localISO.locale = Locale(identifier: "en_US_POSIX")
        localISO.timeZone = TimeZone(secondsFromGMT: 0)
        localISO.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let d = localISO.date(from: raw) { return d }

        localISO.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = localISO.date(from: raw) { return d }

        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .iso8601)
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(secondsFromGMT: 0)
        dateOnly.dateFormat = "yyyy-MM-dd"
        if let d = dateOnly.date(from: raw) { return d }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid date: \(raw)"
        )
    }
}

extension JSONDecoder {
    static func gustavSupabaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .supabaseISO8601
        return decoder
    }
}

/*
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .supabaseISO8601
이 decoder를 SupabaseClient 생성할 때 넣는 방식
*/
