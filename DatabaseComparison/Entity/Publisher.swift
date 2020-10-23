struct Publisher: Decodable {
    let id: Int
    let name: String
    let books: [Book]
    let owner: Owner
}
