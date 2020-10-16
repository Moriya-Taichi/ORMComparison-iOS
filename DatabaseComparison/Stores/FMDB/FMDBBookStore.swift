
import FMDB

final class FMDBBookStore: FMDBBookStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

    init(databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
    }

    func create(object: Book) {

    }

    func read() -> [Book]? {

    }

    func update(object: Book) {

    }

    func delete(object: Book) {

    }
}
