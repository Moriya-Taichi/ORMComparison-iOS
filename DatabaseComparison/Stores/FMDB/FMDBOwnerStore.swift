import Foundation

final class FMDBOwnerStore: FMDBStore {

    let databaseWrapper: FMDBDatabaseWrapeer

    init(databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
    }

    func create(object: Owner) {

    }

    func read() -> [Owner]? {

    }

    func update(object: Owner) {

    }

    func delete(object: Owner) {
        
    }
}
