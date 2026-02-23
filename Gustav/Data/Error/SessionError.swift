//
//  SessionError.swift
//  Gustav
//
//  Created by kaeun on 2/13/26.
//

import Foundation

public enum SessionError: Error, Equatable {
    case sessionNotFound                       // 로컬 세션 없음
    case loadFailed
    case saveFailed
    case invalidData
    case clearFailed
}
