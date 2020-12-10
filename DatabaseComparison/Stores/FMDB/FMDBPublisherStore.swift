import FMDB

final class FMDBPublisherStore: PublisherStore {

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
        "publishers (id, name, owner_id) " +
        "VALUES " +
        "(?, ?, ?);"

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

    func create(publisher: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            insertSQL,
            values: [
                publisher.id,
                publisher.name,
                publisher.owner.id
            ]
        )
        ownerStore.create(owner: publisher.owner)
        bookStore.createBooks(books: publisher.books, publisherID: publisher.id)
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

    func read() -> [Publisher] {
        var publishers: [Publisher] = []
        let query = "SELECT * FROM publishers " +
            "LEFT JOIN books ON publishers.id == books.publisher_id " +
            "LEFT JOIN owners ON publishers.owner_id == owners.id;"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: nil
            ) {
            var publisher: Publisher? = nil
            while result.next() {
                if publisher == nil {
                    let owner = Owner(
                        id: Int(result.int(forColumn: "owners.id")),
                        name: result.string(forColumn: "owners.name") ?? "",
                        age: Int(result.int(forColumn: "owners.age")),
                        profile: result.string(forColumn: "owners.profile") ?? ""
                    )
                    publisher = .init(
                        id: Int(result.int(forColumn: "publishers.id")),
                        name: result.string(forColumn: "publishers.name") ?? "",
                        books: [],
                        owner: owner
                    )
                }

                guard var publisher = publisher else {
                    continue
                }

                if publisher.id == Int(result.int(forColumn: "publishers.id")) {
                    let book = Book(
                        id: Int(result.int(forColumn: "books.id")),
                        name: result.string(forColumn: "books.name") ?? "",
                        price: Int(result.int(forColumn: "books.price"))
                    )
                    publisher = .init(
                        id: publisher.id,
                        name: publisher.name,
                        books: publisher.books + [book],
                        owner: publisher.owner
                    )
                }
                else {
                    publishers.append(publisher)
                    let owner = Owner(
                        id: Int(result.int(forColumn: "owners.id")),
                        name: result.string(forColumn: "owners.name") ?? "",
                        age: Int(result.int(forColumn: "owners.age")),
                        profile: result.string(forColumn: "owners.profile") ?? ""
                    )
                    publisher = .init(
                        id: Int(result.int(forColumn: "publishers.id")),
                        name: result.string(forColumn: "publishers.name") ?? "",
                        books: [],
                        owner: owner
                    )
                }
            }
        }
        return publishers
    }

    func update (publisher: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            updateSQL,
            values: [
                publisher.name,
                publisher.owner.id,
                publisher.id
            ]
        )

        bookStore.updateByBooks(books: publisher.books, publisherID: publisher.id)
        ownerStore.update(owner: publisher.owner)
    }

    func delete(publisher: Publisher) {
        try? databaseWrapper.executeUpdate(deleteSQL, values: [publisher.id])
        bookStore.deleteByPublisherID(publisherID: publisher.id)
    }
}
