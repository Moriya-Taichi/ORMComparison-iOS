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
        let query = "SELECT publishers.id, publishers.name, books.id, books.name, books.price, owners.id, owners.name, owners.age, owners.profile FROM publishers " +
            "LEFT JOIN books ON publishers.id == books.publisher_id " +
            "LEFT JOIN owners ON publishers.owner_id == owners.id;"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: nil
            ) {
            var currentPublisher = Publisher(
                id: 0,
                name: "",
                books: [],
                owner: .init(
                    id: 0,
                    name: "",
                    age: 0,
                    profile: "")
            )
            var books: [Book] = []
            while result.next() {
                if currentPublisher.id != Int(result.int(forColumnIndex: 0)) {
                    publishers.append(currentPublisher)
                    books = []
                }

                let book = Book(
                    id: Int(result.int(forColumnIndex: 2)),
                    name: result.string(forColumnIndex: 3) ?? "",
                    price: Int(result.int(forColumnIndex: 4))
                )
                books.append(book)

                currentPublisher = Publisher(
                    id: Int(result.int(forColumnIndex: 0)),
                    name: result.string(forColumnIndex: 1) ?? "",
                    books: books,
                    owner: .init(
                        id: Int(result.int(forColumnIndex: 5)),
                        name: result.string(forColumnIndex: 6) ?? "",
                        age: Int(result.int(forColumnIndex: 7)),
                        profile: result.string(forColumnIndex: 8) ?? ""
                    )
                )
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
