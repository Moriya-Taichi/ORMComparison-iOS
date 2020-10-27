import Foundation

final class UserDefaultsStore {

    private let defaults = UserDefaults.standard

    func create(publisher: Publisher) {
        var storedPublishers = read()
        storedPublishers?.append(publisher)
        let publishersData = try? JSONEncoder().encode(storedPublishers)
        defaults.setValue(publishersData, key: .publisher)
    }

    func read () -> [Publisher]? {
        guard
            let data = defaults.data(.publisher),
            let publishers = try? JSONDecoder().decode(
                [Publisher].self,
                from: data
            )
        else {
            return nil
        }
        return publishers
    }

    func update (publisher: Publisher) {
        guard
            let data = defaults.data(.publisher),
            var publishers = try? JSONDecoder().decode(
                [Publisher].self,
                from: data
            ),
            let index = publishers.firstIndex(where: { $0.id == publisher.id })
        else {
            return
        }
        publishers.remove(at: index)
        publishers.append(publisher)
        let publishersData = try? JSONEncoder().encode(publishers)
        defaults.setValue(publishersData, key: .publisher)
    }

    func delete (publisher: Publisher) {
        guard
            let data = defaults.data(.publisher),
            var publishers = try? JSONDecoder().decode(
                [Publisher].self,
                from: data
            ),
            let index = publishers.firstIndex(where: { $0.id == publisher.id })
        else {
            return
        }
        publishers.remove(at: index)
        let publishersData = try? JSONEncoder().encode(publishers)
        defaults.setValue(publishersData, key: .publisher)
    }
}

extension UserDefaults {
    func setValue(_ value: Any?, key: DefaultsKey) {
        self.setValue(value, forKey: key.rawValue)
    }

    func data(_ key: DefaultsKey) -> Data? {
        return self.data(forKey: key.rawValue)
    }
}
