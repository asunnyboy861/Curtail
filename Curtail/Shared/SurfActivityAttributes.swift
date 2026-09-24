import Foundation

import ActivityKit

struct SurfActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
    }
    var profileName: String
}
