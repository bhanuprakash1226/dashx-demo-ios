//
//  String+DashX.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import Foundation
import UIKit

extension String {
    func isValidEmail() -> Bool {
        let emailStr = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let emailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: emailStr)
    }
    
    func postedDate() -> String {
        let date = DateFormatter.fullDate.date(from: self) ?? Date()
        let postedDate = "Posted \(Date.timeIntervalDifference(toDate: date))"
        return postedDate
    }
    
    func getImage() -> UIImage? {
        if let url = URL(string: self),
           let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
}
