struct Publisher: Codable, Hashable {
    let id: Int
    let name: String
    let books: [Book]
    let owner: Owner

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: Publisher.self))
        hasher.combine(id)
    }
}
