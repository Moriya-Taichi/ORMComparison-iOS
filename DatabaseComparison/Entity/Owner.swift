struct Owner: Codable, Hashable {
    let id: Int
    let name: String
    let age: Int
    let profile: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: Owner.self))
        hasher.combine(id)
    }
}
