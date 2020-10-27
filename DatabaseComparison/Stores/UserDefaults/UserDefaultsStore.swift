import Foundation

final class UserDefaultsStore {

    private let defaults = UserDefaults.standard

    func create(publisher: Publisher) {
        var storedPublishers = read()
        storedPublishers.append(publisher)
        let publishersData = try? JSONEncoder().encode(storedPublishers)
        defaults.setValue(publishersData, key: .publisher)
    }

    func read () -> [Publisher] {
        return []
    }

    func update (publisher: Publisher) {

    }

    func delete (publisher: Publisher) {

    }
}

extension UserDefaults {
    func setValue(_ value: Any?, key: DefaultsKey) {
        self.setValue(value, forKey: key.rawValue)
    }
}
