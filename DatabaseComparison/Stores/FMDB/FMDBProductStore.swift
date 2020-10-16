
import FMDB

final class FMDBProductStore: FMDBProductStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

    init(databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
    }

    func create(object: Product) {

    }

    func read() -> [Product]? {

    }

    func update(object: Product) {

    }

    func delete(object: Product) {

    }
}
