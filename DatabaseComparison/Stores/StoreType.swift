
protocol Store {
    associatedtype StoredObjectType

    func create(object: StoredObjectType)
    func read() -> [StoredObjectType]?
    func update(object: StoredObjectType)
    func delete(object: StoredObjectType)
}
