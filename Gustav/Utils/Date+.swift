//
//  Date+.swift
//  Gustav
//
//  Created by 박선린 on 3/5/26.
//
import Foundation

extension Date {
    func formatDateyyyyMMdd() -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy.MM.dd"
       formatter.locale = Locale.current
       return formatter.string(from: self)
   }
}
