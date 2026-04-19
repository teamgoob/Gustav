//
//  JSONDecoder+SupabaseDate.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//

import Foundation

enum SupabaseDateParser {
    static func parse(
        _ raw: String,
        dateOnlyTimeZone: TimeZone = .autoupdatingCurrent
    ) -> Date? {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) { return date }

        let isoFrac = ISO8601DateFormatter()
        isoFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFrac.date(from: raw) { return date }

        let utcISO = DateFormatter()
        utcISO.calendar = Calendar(identifier: .iso8601)
        utcISO.locale = Locale(identifier: "en_US_POSIX")
        utcISO.timeZone = TimeZone(secondsFromGMT: 0)
        utcISO.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = utcISO.date(from: raw) { return date }

        utcISO.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = utcISO.date(from: raw) { return date }

        // Date-only payloads mean the backend already discarded the time component.
        // Decode them at local midnight so users do not see an artificial 9:00 AM in KST.
        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .iso8601)
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = dateOnlyTimeZone
        dateOnly.dateFormat = "yyyy-MM-dd"
        return dateOnly.date(from: raw)
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let supabaseISO8601: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        if let date = SupabaseDateParser.parse(raw) {
            return date
        }

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
