
protocol FMDBStoreType: StoreType {
    var databaseWrapper: FMDBDatabaseWrapeer { get }

    init (databaseWrapper: FMDBDatabaseWrapeer)
}

protocol FMDBPublisherStoreType: FMDBStoreType where StoredObjectType == Publisher {}

protocol FMDBOwnerStoreType: FMDBStoreType where StoredObjectType == Owner {}

protocol FMDBBookStoreType: FMDBStoreType where StoredObjectType == Book {}
