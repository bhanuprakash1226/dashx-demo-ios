import Foundation

extension Date {
    static var second: Double {
        return 1
    }
    
    static var minute: Double {
        return second * 60
    }
    
    static var hour: Double {
        return minute * 60
    }
    
    static var day: Double {
        return hour * 24
    }
    
    static func timeIntervalDifference(between fromDate: Date = Date(), toDate: Date) -> String {
        let secondsDiffered = Double(fromDate.timeIntervalSince1970) - Double(toDate.timeIntervalSince1970)
        
        guard secondsDiffered > 0 else {
            return "now"
        }
        
        if secondsDiffered < Date.minute {
            if secondsDiffered <= second {
                return "a second ago"
            } else {
                let timeIntervalString = String(format: "%.f", secondsDiffered)
                return "\(timeIntervalString) seconds ago"
            }
        }
        
        if secondsDiffered < Date.hour {
            let min = secondsDiffered / Date.minute
            let remainingSeconds = Double(secondsDiffered.truncatingRemainder(dividingBy: Date.minute))
            if Int(min) == 1 && remainingSeconds < Date.second {
                return "a min ago"
            }
            return (remainingSeconds >= Date.second) ? "\(Int(min) + 1) mins ago" : "\(Int(min)) mins ago"
        }
        
        if secondsDiffered < Date.day {
            let hrs = secondsDiffered / Date.hour
            let remainingSeconds = secondsDiffered.truncatingRemainder(dividingBy: Date.hour)
            if Int(hrs) == 1 && remainingSeconds < Date.minute {
                return "a hour ago"
            }
            return (remainingSeconds >= Date.minute) ? "\(Int(hrs) + 1) hours ago" : "\(Int(hrs) + 1) hours ago"
        }
        
        let days = Int(secondsDiffered / Date.day)
        let remainingHours = secondsDiffered.truncatingRemainder(dividingBy: Date.day) / Date.hour
        if Int(days) == 1 && remainingHours < Date.hour {
            return "a day ago"
        }
        return (remainingHours >= Date.hour) ? "\(Int(days) + 1) days ago" : "\(Int(days)) days ago"
    }
}
