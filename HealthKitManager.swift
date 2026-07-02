import Foundation
import HealthKit

final class HealthKitManager {
    private let store = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorisation() async throws {
        guard isAvailable else { return }
        let workoutType = HKObjectType.workoutType()
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceSwimming)!
        let typesToShare: Set = [workoutType, distanceType]
        let typesToRead: Set = [workoutType, distanceType]
        try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    // Saves a swim session as a workout in Apple Health.
    func saveWorkout(for session: SwimSession) async throws {
        guard isAvailable else { return }

        let start = session.date
        let end = session.date.addingTimeInterval(session.durationSeconds)

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .swimming
        configuration.swimmingLocationType = .pool

        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        try await builder.beginCollection(at: start)

        let distanceType = HKQuantityType(.distanceSwimming)
        let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: Double(session.distanceMetres))
        let distanceSample = HKQuantitySample(
            type: distanceType,
            quantity: distanceQuantity,
            start: start,
            end: end
        )
        try await builder.addSamples([distanceSample])
        try await builder.endCollection(at: end)
        _ = try await builder.finishWorkout()
    }
}
