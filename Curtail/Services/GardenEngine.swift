import Foundation

struct GardenPlant: Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let scale: Double
    let isFlower: Bool
    let hue: Double
}

enum GardenEngine {
    static func plants(for profile: SubstanceProfile, now: Date = .now) -> [GardenPlant] {
        let days = min(120, Int(now.timeIntervalSince(profile.currentLapStart) / 86400))
        let maintained = days + profile.totalRiddenCravings
        var generator = SeededRandom(seed: UInt64(profile.gardenSeed))
        var plants: [GardenPlant] = []
        let count = min(maintained, 48)
        for i in 0..<count {
            let isFlower = i % 4 == 0
            plants.append(GardenPlant(
                id: i,
                x: 0.06 + generator.nextDouble() * 0.88,
                y: 0.35 + generator.nextDouble() * 0.6,
                scale: 0.5 + generator.nextDouble() * 0.8,
                isFlower: isFlower,
                hue: generator.nextDouble()
            ))
        }
        return plants.sorted { $0.y < $1.y }
    }

    static func growthLevel(for profile: SubstanceProfile) -> Int {
        let riddenScore = Double(profile.totalRiddenCravings) * 8.0
        let daysScore = Double(now_days(profile)) * 2.0
        let level = Int(riddenScore + daysScore)
        return min(100, level)
    }

    private static func now_days(_ p: SubstanceProfile) -> Int {
        Int(Date.now.timeIntervalSince(p.currentLapStart) / 86400)
    }
}

struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E3779B97F4A7C15 }
    mutating func nextDouble() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(UInt64.max >> 11)
    }
}
