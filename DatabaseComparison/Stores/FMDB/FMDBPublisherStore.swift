import FMDB

final class FMDBPublisherStore {

    private let databaseWrapper: FMDBDatabaseWrapeer
    private let bookStore: FMDBBookStore
    private let ownerStore: FMDBOwnerStore

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS publishers (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "owner_id INTEGER" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "publishers (name, owner_id) " +
        "VALUES " +
        "(?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, owner_id " +
        "FROM " +
        "publishers;" +
        "ORDER BY id;"

    private let updateSQL =
        "UPDATE " +
        "publishers " +
        "SET " +
        "name = ?, owner_id = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM publishers WHERE id = ?;"


    init (
        databaseWrapper: FMDBDatabaseWrapeer,
        bookStore: FMDBBookStore,
        ownerStore: FMDBOwnerStore
    ) {
        self.databaseWrapper = databaseWrapper
        self.bookStore = bookStore
        self.ownerStore = ownerStore
        try? databaseWrapper
            .executeUpdate(createTableSQL, values: nil)
    }

    func create(object: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            insertSQL,
            values: [
            ]
        )
    }

    func readByLazyLoading () -> [Publisher] {
        var temporaryPublishers: [(
            id: Int,
            name: String,
            ownerId: Int
        )] = []
        if
            let result = try? databaseWrapper
                .executeQuery(
                selectSQL,
                values: nil
        ) {
            while result.next() {
                temporaryPublishers.append(
                    (
                        id: result.long(forColumnIndex: 0),
                        name: result.string(forColumnIndex: 0) ?? "",
                        ownerId: result.long(forColumnIndex: 0)
                    )
                )
            }
        }

        let publisherIDs = temporaryPublishers.map { $0.id }
        let books = bookStore.readBooksWithIDByPublisherIDs(publisherIDs)
        let ownerIDs = temporaryPublishers.map { $0.ownerId }
        let owners = ownerStore.readByIDs(Array(Set(ownerIDs)))
        
        return temporaryPublishers.compactMap { publisher -> Publisher? in
            guard
                let owner = owners
                    .filter({ $0.id == publisher.ownerId })
                    .first
            else {
                return nil
            }
            let book = books
                .filter { $0.id == publisher.id }
                .map { $0.book }
            return Publisher(
                id: publisher.id,
                name: publisher.name,
                books: book,
                owner: owner
            )
        }
    }

    func readByEagerLoading() -> [Publisher] {
        var publishers: [Publisher] = []
        let query = "SELECT * FROM publishers JOIN books ON publsihers.id == books.id"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: nil
            ) {
            while result.next() {
            }
        }
        return publishers
    }

    func update (object: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            updateSQL,
            values: [
            ]
        )
    }

    func delete(object: Publisher) {
        try? databaseWrapper.executeUpdate(deleteSQL, values: [])
    }
}
