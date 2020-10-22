import Foundation
import GRDB

final class GRDBPublisherStore {

    private let databaseQueue: DatabaseQueue

    init (databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }
}
