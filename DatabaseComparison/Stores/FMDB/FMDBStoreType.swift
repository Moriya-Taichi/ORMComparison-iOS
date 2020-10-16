
protocol FMDBStoreType: StoreType {
    var databaseWrapper: FMDBDatabaseWrapeer { get }

    init (databaseWrapper: FMDBDatabaseWrapeer)
}

protocol FMDBShopStoreType: FMDBStoreType where StoredObjectType == Shop {}

protocol FMDBOwnerStoreType: FMDBStoreType where StoredObjectType == Owner {}

protocol FMDBProductStoreType: FMDBStoreType where StoredObjectType == Product {}
