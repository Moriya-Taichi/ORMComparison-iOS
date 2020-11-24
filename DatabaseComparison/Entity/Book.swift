struct Book: Codable, Hashable {
    let id: Int
    let name: String
    let price: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: Book.self))
        hasher.combine(id)
    }
}
