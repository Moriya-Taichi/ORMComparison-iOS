
import Foundation

protocol FMDBStore: Store {
    var databaseWrapper: FMDBDatabaseWrapeer { get }

    init (databaseWrapper: FMDBDatabaseWrapeer)
}
