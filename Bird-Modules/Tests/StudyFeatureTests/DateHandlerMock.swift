//
//  DateHandlerMock.swift
//  
//
//  Created by Marcos Chevis on 06/09/22.
//
import Foundation
import StudyFeature

struct DateHandlerMock: DateHandlerProtocol {
    var shouldMockIsToday: Bool = false
    var expectedIsToday: Bool = false
    var today: Date {
        Date(timeIntervalSince1970: 0)
    }
    
    func isToday(date: Date) -> Bool {
        if shouldMockIsToday {
            return expectedIsToday
        }
        var cal = Calendar(identifier: .gregorian)
        guard let timezone = TimeZone(identifier: "UTC") else {
            return false
        }
        cal.timeZone = timezone
        
        return cal.dateComponents([.day], from: date) == cal.dateComponents([.day], from: today)
    }
    

}
