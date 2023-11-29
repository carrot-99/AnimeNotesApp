//  Components/StatusIconMapping.swift

import Foundation

func iconForStatus(_ status: Int) -> String {
    switch status {
    case 0: return "circle"
    case 1: return "play.circle"
    case 2: return "pause.circle"
    case 3: return "checkmark.circle"
    case 4: return "calendar.circle"
    default: return "circle"
    }
}
